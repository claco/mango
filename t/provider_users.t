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
        plan tests => 69;
    };

    use_ok('Mango::Provider::Users');
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


## get by user (mapped to get_by_id for this provider)
{
    my $user = $provider->get_by_user(2);
    isa_ok($user, 'Mango::User');
    is($user->id, 2);
    is($user->username, 'test2');
    is($user->password, 'password2');
    is($user->created, '2004-07-04T12:00:00');
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


## create
{
    my $current = DateTime->now;
    my $user = $provider->create({
        username => 'user1',
        password => 'password1'
    });
    isa_ok($user, 'Mango::User');
    ok($user->id);
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
    ok($user->id);
    is($user->username, 'user2');
    is($user->password, 'password2');
    cmp_ok($user->created->epoch, '>=', $current->epoch);
    is($provider->search->count, 5);
};
