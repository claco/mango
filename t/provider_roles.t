#!perl -w
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
        plan tests => 145;
    };

    use_ok('Mango::Provider::Roles');
    use_ok('Mango::Exception', ':try');
    use_ok('Mango::Role');
    use_ok('Mango::User');
};

my $schema = Mango::Test->init_schema;
my $provider = Mango::Provider::Roles->new({
    #connection_info => [$schema->dsn]
    #use faster test schema
    schema => $schema
});
isa_ok($provider, 'Mango::Provider::Roles');


## get by id
{
    my $role = $provider->get_by_id(1);
    isa_ok($role, 'Mango::Role');
    is($role->id, 1);
    is($role->name, 'role1');
    is($role->description, 'Role1');
    is($role->created, '2004-07-04T12:00:00');
};


## get by id w/object
{
    my $object = Mango::Object->new;
    $object->id(2);
    my $role = $provider->get_by_id($object);
    isa_ok($role, 'Mango::Role');
    is($role->id, 2);
    is($role->name, 'role2');
    is($role->description, 'Role2');
    is($role->created, '2004-07-04T12:00:00');
};


## get by id for nothing
{
    my $role = $provider->get_by_id(100);
    is($role, undef);
};


## get by user
{
    my @roles = $provider->search({ user => 2 });
    is(scalar @roles, 1);
    my $role = $roles[0];
    isa_ok($role, 'Mango::Role');
    is($role->id, 1);
    is($role->name, 'role1');
    is($role->description, 'Role1');
    is($role->created, '2004-07-04T12:00:00');
};


## get by user w/ object
{
    my $user = Mango::User->new({
        id => 1
    });
    my @roles = $provider->search({ user => $user });
    is(scalar @roles, 2);
    my $role = $roles[0];
    isa_ok($role, 'Mango::Role');
    is($role->id, 1);
    is($role->name, 'role1');
    is($role->description, 'Role1');
    is($role->created, '2004-07-04T12:00:00');

    $role = $roles[1];
    isa_ok($role, 'Mango::Role');
    is($role->id, 2);
    is($role->name, 'role2');
    is($role->description, 'Role2');
    is($role->created, '2004-07-04T12:00:00');
};


## get by user for nothing
{
    my $roles = $provider->search({ user => 100 });
    isa_ok($roles, 'Mango::Iterator');
    is($roles->count, 0);
};


## search w/iterator
{
    my $roles = $provider->search;
    isa_ok($roles, 'Mango::Iterator');
    is($roles->count, 2);

    for (1..2) {
        my $role = $roles->next;
        isa_ok($role, 'Mango::Role');
        is($role->id, $_);
        is($role->name, "role$_");
        is($role->description, "Role$_");
        is($role->created, '2004-07-04T12:00:00');
    };
};


## search as list (with order_by)
{
    my @roles = $provider->search(undef, {order_by => 'id desc'});
    is($#roles, 1);

    my $role = $roles[0];
    isa_ok($role, 'Mango::Role');
    is($role->id, 2);
    is($role->name, 'role2');
    is($role->description, 'Role2');
    is($role->created, '2004-07-04T12:00:00');

    $role = $roles[1];
    isa_ok($role, 'Mango::Role');
    is($role->id, 1);
    is($role->name, 'role1');
    is($role->description, 'Role1');
    is($role->created, '2004-07-04T12:00:00');
};


## search w/filter
{
    my $roles = $provider->search({name => 'role2'});
    isa_ok($roles, 'Mango::Iterator');
    is($roles->count, 1);

    my $role = $roles->next;
    isa_ok($role, 'Mango::Role');
    is($role->id, 2);
    is($role->name, 'role2');
    is($role->description, 'Role2');
    is($role->created, '2004-07-04T12:00:00');
};


## search w/existing join (as array) and user
{
    my $roles = $provider->search({user => 2}, {
        join => ['map_user_role']
    });
    isa_ok($roles, 'Mango::Iterator');
    is($roles->count, 1);

    my $role = $roles->next;
    isa_ok($role, 'Mango::Role');
    is($role->id, 1);
    is($role->name, 'role1');
    is($role->description, 'Role1');
    is($role->created, '2004-07-04T12:00:00');
};


## search w/existing join (as string) and user
{
    my $roles = $provider->search({user => 2}, {
        join => 'map_user_role'
    });
    isa_ok($roles, 'Mango::Iterator');
    is($roles->count, 1);

    my $role = $roles->next;
    isa_ok($role, 'Mango::Role');
    is($role->id, 1);
    is($role->name, 'role1');
    is($role->description, 'Role1');
    is($role->created, '2004-07-04T12:00:00');
};


## search w/existing join (as hash) and user
{
    my $roles = $provider->search({user => 2}, {
        join => {'map_user_role' => 'user'}
    });
    isa_ok($roles, 'Mango::Iterator');
    is($roles->count, 1);

    my $role = $roles->next;
    isa_ok($role, 'Mango::Role');
    is($role->id, 1);
    is($role->name, 'role1');
    is($role->description, 'Role1');
    is($role->created, '2004-07-04T12:00:00');
};


## search for nothing
{
    my $roles = $provider->search({name => 'foooz'});
    isa_ok($roles, 'Mango::Iterator');
    is($roles->count, 0);
};


## create
{
    my $current = DateTime->now;
    my $role = $provider->create({
        name => 'role3',
        description => 'Role3'
    });
    isa_ok($role, 'Mango::Role');
    is($role->id, 3);
    is($role->name, 'role3');
    is($role->description, 'Role3');
    cmp_ok($role->created->epoch, '>=', $current->epoch);
    is($provider->search->count, 3);
};


## create w/DateTime
{
    my $current = DateTime->now;
    my $role = $provider->create({
        name => 'role4',
        description => 'Role4',
        created  => DateTime->now
    });
    isa_ok($role, 'Mango::Role');
    is($role->id, 4);
    is($role->name, 'role4');
    is($role->description, 'Role4');
    cmp_ok($role->created->epoch, '>=', $current->epoch);
    is($provider->search->count, 4);
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

    my $role = Mango::Role->new({
        id => 4,
        name => 'updatedrole4',
        description => 'UpdatedRole4',
        created  => $date
    });

    ok($provider->update($role));

    my $updated = $provider->get_by_id(4);    
    isa_ok($updated, 'Mango::Role');
    is($updated->id, 4);
    is($updated->name, 'updatedrole4');
    is($updated->description, 'UpdatedRole4');
    cmp_ok($updated->created->epoch, '=', $date->epoch);
    is($provider->search->count, 4);
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

    my $role = Mango::Role->new({
        id => 3,
        name => 'updateduser3',
        description => 'UpdatedDescription3',
        created  => $date,
        meta => {
            provider => $provider
        }
    });
    ok($role->update);

    my $updated = $provider->get_by_id(3);
    isa_ok($updated, 'Mango::Role');
    is($updated->id, 3);
    is($updated->name, 'updateduser3');
    is($updated->description, 'UpdatedDescription3');
    cmp_ok($updated->created->epoch, '=', $date->epoch);
    is($provider->search->count, 4);
};


## delete using id
{
    ok($provider->delete(4));
    is($provider->search->count, 3);
    is($provider->get_by_id(4), undef);
};


## delete using hash
{
    ok($provider->delete({id => 3}));
    is($provider->search->count, 2);
    is($provider->get_by_id(3), undef);
};


## delete using object
{
    my $role = Mango::Role->new({
        id => 2
    });
    ok($provider->delete($role));
    is($provider->search->count, 1);
    is($provider->get_by_id(2), undef);
};


## delete on result object
{
    my $role = Mango::Role->new({
        id => 1,
        meta => {
            provider => $provider
        }
    });
    ok($role->destroy);
    is($provider->search->count, 0);
    is($provider->get_by_id(1), undef);
};


## add a role and add a user
{
    my $role = $provider->create({
        name => 'New Role'
    });

    my $user = Mango::User->new({
        id => 2
    });

    is($provider->search({user => 1})->count, 0);
    $role->add_users(1);    
    $provider->add_users($role->id, $user);

    my $roles = $provider->search({user => 1});
    is($roles->count, 1);
    is($roles->first->name, 'New Role');

    $roles = $provider->search({user => $user});
    is($roles->count, 1);
    is($roles->first->name, 'New Role');
};


## delete users from a role
{
    my $role = $provider->search({
        name => 'New Role'
    })->first;

    my $user = Mango::User->new({
        id => 2
    });

    is($provider->search({user => 1})->count, 1);
    $role->remove_users(1);
    is($provider->search({user => 1})->count, 0);

    is($provider->search({user => $user})->count, 1);
    $provider->remove_users($role->id, $user);
    is($provider->search({user => $user})->count, 0);
};


## add_user throws exception when role isn't a role object
{
    my $role = $provider->search->first;

    try {
        local $ENV{'LANG'} = 'en';
        $provider->add_users(bless({}, 'Junk'), 1);

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/not a Mango::Role/i, 'not a Mango::Role');
    } otherwise {
        fail('Other exception thrown');
    };
};


## add_user throws exception when user isn't a user object
{
    my $role = $provider->search->first;

    try {
        local $ENV{'LANG'} = 'en';
        $provider->add_users($role, bless({}, 'Junk'));

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/not a Mango::User/i, 'not a Mango::User');
    } otherwise {
        fail('Other exception thrown');
    };
};


## remove_user throws exception when role isn't a role object
{
    my $role = $provider->search->first;

    try {
        local $ENV{'LANG'} = 'en';
        $provider->remove_users(bless({}, 'Junk'), 1);

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/not a Mango::Role/i, 'not a Mango::Role');
    } otherwise {
        fail('Other exception thrown');
    };
};


## remove_user throws exception when user isn't a user object
{
    my $role = $provider->search->first;

    try {
        local $ENV{'LANG'} = 'en';
        $provider->remove_users($role, bless({}, 'Junk'));

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/not a Mango::User/i, 'not a Mango::User');
    } otherwise {
        fail('Other exception thrown');
    };
};


## search throws exception when user isn't a user object
{
    try {
        local $ENV{'LANG'} = 'en';
        $provider->search({
            user => bless({}, 'Junk')
        });

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/not a Mango::User/i, 'not a Mango::User');
    } otherwise {
        fail('Other exception thrown');
    };
};
