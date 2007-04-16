#!perl -wT
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test;

    eval 'require DBD::SQLite';
    if($@) {
        plan skip_all => 'DBD::SQLite not installed';
    } else {
        plan tests => 74;
    };

    use_ok('Mango::Provider::DBIC');
    use_ok('Mango::Exception', ':try');
    use_ok('Mango::Object');
    use_ok('Mango::Schema');
};

my $schema = Mango::Test->init_schema;
my $provider = Mango::Provider::DBIC->new({
    connection_info => [$schema->dsn],
});
isa_ok($provider, 'Mango::Provider::DBIC');

is($provider->result_class, undef);
is($provider->_schema, undef);
is($provider->_resultset, undef);
is($provider->source_name, undef);
is($provider->schema_class, 'Mango::Schema');

$provider->schema_class('Mango::Test::Schema');
is($provider->schema_class, 'Mango::Test::Schema');
isa_ok($provider->schema, 'Mango::Test::Schema');

$provider->source_name('Users');
is($provider->source_name, 'Users');
isa_ok($provider->resultset, 'DBIx::Class::ResultSet');
is($provider->resultset->result_source->source_name, 'Users');

$provider->result_class('Mango::Object');
is($provider->result_class, 'Mango::Object');

## search into list
{
    my @users = $provider->search({id => 1});
    is(scalar @users, 1);
    my $user = shift @users;
    isa_ok($user, 'Mango::Object');
    is($user->data->{'id'}, 1);
    is($user->data->{'username'}, 'test1');
};

## search into iterator
{
    my $users = $provider->search({id => 2});
    isa_ok($users, 'Mango::Iterator');
    is($users->count, 1);
    my $user = $users->next;
    isa_ok($user, 'Mango::Object');
    is($users->pager, undef);
    is($user->data->{'id'}, 2);
    is($user->data->{'username'}, 'test2');
};


## search into iterator with pager
{
    my $users = $provider->search(undef, {
        rows => 1, page => 1
    });
    isa_ok($users, 'Mango::Iterator');
    is($users->count, 1);
    isa_ok($users->pager, 'Data::Page');
    is($users->pager->last_page, 3);
    my $user = $users->next;
    isa_ok($user, 'Mango::Object');
    is($user->data->{'id'}, 1);
    is($user->data->{'username'}, 'test1');
};


## search w/ options
{
    my @users = $provider->search({}, {order_by => 'id desc'});
    is(scalar @users, 3);
    is($users[0]->data->{'id'}, 3);
    is($users[1]->data->{'id'}, 2);
    is($users[2]->data->{'id'}, 1);
};


## update
{
    my $object = Mango::Object->new({
        provider => $provider,
        data => {
            id => 1,
            username => 'updateduser1',
            password => 'updatedpassword1'
        }
    });

    ok($provider->update($object));
    
    my $user = $provider->resultset->find(1);
    is($user->id, 1);
    is($user->username, 'updateduser1');
    is($user->password, 'updatedpassword1');
};

## create
{
    my $object = $provider->create({
        username => 'newuser',
        password => 'newpass'
    });
    isa_ok($object, 'Mango::Object');
    is($object->data->{'id'}, 4);
    is($object->data->{'username'}, 'newuser');
    is($object->data->{'password'}, 'newpass');
    isa_ok($object->data->{'created'}, 'DateTime');

    my $user = $provider->resultset->find(4);
    is($user->id, 4);
    is($user->username, 'newuser');
    is($user->password, 'newpass');
    isa_ok($user->created, 'DateTime');
};


## delete w/id
{
    is($provider->resultset->count, 4);
    ok($provider->delete(1));
    is($provider->resultset->count, 3);
    is($provider->resultset->find(1), undef);
};


## delete w/object
{
    is($provider->resultset->count, 3);

    my $object = Mango::Object->new({
        data => {
            id => 2
        }
    });
    ok($provider->delete($object));
    is($provider->resultset->count, 2);
    is($provider->resultset->find(2), undef);
};


## delete w/hash
{
    is($provider->resultset->count, 2);
    ok($provider->delete({ id => 3 }));
    is($provider->resultset->count, 1);
    is($provider->resultset->find(1), undef);
};


## search using cusotm resultset
{
    is($provider->resultset->count, 1);
    $provider->create({
        username => 'customusername',
        password => 'custompassword'
    });
    is($provider->resultset->count, 2);

    $provider->resultset(
        $provider->schema->resultset('Users')->search_rs({
            username => 'customusername'
        })
    );
    is($provider->resultset->count, 1);
};


## resultset goes boom when source_name is junk
{
    $provider->_resultset(undef);
    $provider->source_name('Junk');

    try {
        local $ENV{'LANG'} = 'en';
        $provider->resultset;

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/source Junk not found/i, 'source not found');
    } otherwise {
        fail('Other exception thrown');
    };
};


## resultset goes boom when no source_name is defined
{
    $provider->_resultset(undef);
    $provider->source_name(undef);

    try {
        local $ENV{'LANG'} = 'en';
        $provider->resultset;

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/no schema_source/i, 'no schema_source');
    } otherwise {
        fail('Other exception thrown');
    };
};


## resultset goes boom when no source_name is defined
{
    $provider->_schema(undef);
    $provider->source_name('Users');
    $provider->schema_class(undef);

    try {
        local $ENV{'LANG'} = 'en';
        $provider->schema;

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/no schema_class/i, 'no schema_class');
    } otherwise {
        fail('Other exception thrown');
    };
};


## set schema externally
{
    is($provider->_schema, undef);

    $provider->schema(
        Mango::Schema->connect
    );

    ok($provider->schema);
};


## last resort conneciton_info
{
    $provider->_schema(undef);
    $provider->schema_class('Mango::Schema');
    $provider->connection_info(undef);

    ok($provider->schema);
};