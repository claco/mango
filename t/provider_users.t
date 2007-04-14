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
        plan tests => 94;
    };

    use_ok('Mango::Provider::Users');
    use_ok('Mango::User');
};

my $schema = Mango::Test->init_schema;
my $provider = Mango::Provider::Users->new({
    connection_info => [$schema->dsn]
});
isa_ok($provider, 'Mango::Provider::Users');


## get by id
{
    my $user = $provider->get_by_id(1);
    isa_ok($user, 'Mango::User');
    is($user->id, 1);
    is($user->username, 'test1');
    is($user->password, 'password1');
    is($user->created, '2004-07-04T12:00:00');
};


## get by id w/object
{
    my $object = Mango::Object->new({
       data => {id => 3} 
    });
    my $user = $provider->get_by_id($object);
    isa_ok($user, 'Mango::User');
    is($user->id, 3);
    is($user->username, 'test3');
    is($user->password, 'password3');
    is($user->created, '2004-07-04T12:00:00');
};


## get by id for nothing
{
    my $user = $provider->get_by_id(100);
    is($user, undef);
};


## search w/iterator
{
    my $users = $provider->search;
    isa_ok($users, 'Mango::Iterator');
    is($users->count, 3);

    for (1..3) {
        my $user = $users->next;
        isa_ok($user, 'Mango::User');
        is($user->id, $_);
        is($user->username, "test$_");
        is($user->password, "password$_");
        is($user->created, '2004-07-04T12:00:00');
    };
};


## search as list
{
    my @users = $provider->search;
    is($#users, 2);

    for (1..3) {
        my $user = $users[$_-1];
        isa_ok($user, 'Mango::User');
        is($user->id, $_);
        is($user->username, "test$_");
        is($user->password, "password$_");
        is($user->created, '2004-07-04T12:00:00');
    };
};


## search w/filter
{
    my $users = $provider->search({username => 'test2'});
    isa_ok($users, 'Mango::Iterator');
    is($users->count, 1);

    my $user = $users->next;
    isa_ok($user, 'Mango::User');
    is($user->id, 2);
    is($user->username, 'test2');
    is($user->password, 'password2');
    is($user->created, '2004-07-04T12:00:00');
};


## search for nothing
{
    my $users = $provider->search({username => 'foooz'});
    isa_ok($users, 'Mango::Iterator');
    is($users->count, 0);
};


## create
{
    my $current = DateTime->now;
    my $user = $provider->create({
        username => 'user1',
        password => 'password1'
    });
    isa_ok($user, 'Mango::User');
    is($user->id, 4);
    is($user->username, 'user1');
    is($user->password, 'password1');
    cmp_ok($user->created->epoch, '>=', $current->epoch);
    is($provider->search->count, 4);
};


## create w/DateTime
{
    my $current = DateTime->now;
    my $user = $provider->create({
        username => 'user2',
        password => 'password2',
        created  => DateTime->now
    });
    isa_ok($user, 'Mango::User');
    is($user->id, 5);
    is($user->username, 'user2');
    is($user->password, 'password2');
    cmp_ok($user->created->epoch, '>=', $current->epoch);
    is($provider->search->count, 5);
};


## update directly
{
    my $date = DateTime->new(
        year   => 1964,
        month  => 10,
        day    => 16,
        hour   => 16,
        minute => 12,
        second => 47,
        nanosecond => 500000000,
        time_zone => 'Asia/Taipei',
    );

    my $user = Mango::User->new({
        data => {
            id => 5,
            username => 'updateduser2',
            password => 'updatedpassword2',
            created  => $date
        }
    });

    ok($provider->update($user));

    my $updated = $provider->get_by_id(5);    
    isa_ok($updated, 'Mango::User');
    is($updated->id, 5);
    is($updated->username, 'updateduser2');
    is($updated->password, 'updatedpassword2');
    cmp_ok($updated->created->epoch, '=', $date->epoch);
    is($provider->search->count, 5);
};


## update on result
{
    my $date = DateTime->new(
        year   => 1974,
        month  => 11,
        day    => 12,
        hour   => 13,
        minute => 11,
        second => 42,
        nanosecond => 400000000,
        time_zone => 'Asia/Taipei',
    );

    my $user = Mango::User->new({
        provider => $provider,
        data => {
            id => 4,
            username => 'updateduser1',
            password => 'updatedpassword1',
            created  => $date
        }
    });
    ok($user->update);

    my $updated = $provider->get_by_id(4);
    isa_ok($updated, 'Mango::User');
    is($updated->id, 4);
    is($updated->username, 'updateduser1');
    is($updated->password, 'updatedpassword1');
    cmp_ok($updated->created->epoch, '=', $date->epoch);
    is($provider->search->count, 5);
};


## delete using id
{
    ok($provider->delete(5));
    is($provider->search->count, 4);
    is($provider->get_by_id(5), undef);
};


## delete using hash
{
    ok($provider->delete({id => 4}));
    is($provider->search->count, 3);
    is($provider->get_by_id(4), undef);
};


## delete using object
{
    my $user = Mango::User->new({
        data => {
            id => 3
        }
    });
    ok($provider->delete($user));
    is($provider->search->count, 2);
    is($provider->get_by_id(3), undef);
};


## delete on result object
{
    my $user = Mango::User->new({
        provider => $provider,
        data => {
            id => 2
        }
    });
    ok($user->destroy);
    is($provider->search->count, 1);
    is($provider->get_by_id(2), undef);
};
