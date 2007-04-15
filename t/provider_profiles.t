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
        plan tests => 118;
    };

    use_ok('Mango::Provider::Profiles');
    use_ok('Mango::Exception', ':try');
    use_ok('Mango::Profile');
    use_ok('Mango::User');
};

my $schema = Mango::Test->init_schema;
my $provider = Mango::Provider::Profiles->new({
    connection_info => [$schema->dsn]
});
isa_ok($provider, 'Mango::Provider::Profiles');


## get by id
{
    my $profile = $provider->get_by_id(1);
    isa_ok($profile, 'Mango::Profile');
    is($profile->id, 1);
    is($profile->first_name, 'First1');
    is($profile->last_name, 'Last1');
    is($profile->created, '2004-07-04T12:00:00');
};


## get by id w/object
{
    my $object = Mango::Object->new({
       data => {id => 2} 
    });
    my $profile = $provider->get_by_id($object);
    isa_ok($profile, 'Mango::Profile');
    is($profile->id, 2);
    is($profile->first_name, 'First2');
    is($profile->last_name, 'Last2');
    is($profile->created, '2004-07-04T12:00:00');
};


## get by id for nothing
{
    my $profile = $provider->get_by_id(100);
    is($profile, undef);
};


## get by user
{
    my @profiles = $provider->search({ user => 2 });
    is(scalar @profiles, 1);
    my $profile = $profiles[0];
    isa_ok($profile, 'Mango::Profile');
    is($profile->id, 2);
    is($profile->first_name, 'First2');
    is($profile->last_name, 'Last2');
    is($profile->created, '2004-07-04T12:00:00');
};


## get by user w/ object
{
    my $user = Mango::User->new({
        data => {
            id => 2
        }
    });
    my @profiles = $provider->search({ user => $user });
    is(scalar @profiles, 1);
    my $profile = $profiles[0];
    isa_ok($profile, 'Mango::Profile');
    is($profile->id, 2);
    is($profile->first_name, 'First2');
    is($profile->last_name, 'Last2');
    is($profile->created, '2004-07-04T12:00:00');
};


## get by user for nothing
{
    my $profiles = $provider->search({ id => 100 });
    isa_ok($profiles, 'Mango::Iterator');
    is($profiles->count, 0);
};


## search w/iterator w/order by
{
    my $profiles = $provider->search(undef, {
        order_by => 'id desc'
    });
    isa_ok($profiles, 'Mango::Iterator');
    is($profiles->count, 2);

    my $profile = $profiles->next;
    isa_ok($profile, 'Mango::Profile');
    is($profile->id, 2);
    is($profile->first_name, 'First2');
    is($profile->last_name, 'Last2');
    is($profile->created, '2004-07-04T12:00:00');

    $profile = $profiles->next;
    isa_ok($profile, 'Mango::Profile');
    is($profile->id, 1);
    is($profile->first_name, 'First1');
    is($profile->last_name, 'Last1');
    is($profile->created, '2004-07-04T12:00:00');
};


## search as list
{
    my @profiles = $provider->search;
    is(scalar @profiles, 2);

    for (1..2) {
        my $profile = $profiles[$_-1];
        isa_ok($profile, 'Mango::Profile');
        is($profile->id, $_);
        is($profile->first_name, "First$_");
        is($profile->last_name, "Last$_");
        is($profile->created, '2004-07-04T12:00:00');
    };
};


## search w/filter
{
    my $profiles = $provider->search({first_name => 'First2'});
    isa_ok($profiles, 'Mango::Iterator');
    is($profiles->count, 1);

    my $profile = $profiles->next;
    isa_ok($profile, 'Mango::Profile');
    is($profile->id, 2);
    is($profile->first_name, 'First2');
    is($profile->last_name, 'Last2');
    is($profile->created, '2004-07-04T12:00:00');
};


## search for nothing
{
    my $profiles = $provider->search({first_name => 'foooz'});
    isa_ok($profiles, 'Mango::Iterator');
    is($profiles->count, 0);
};


## create
{
    my $current = DateTime->now;
    my $profile = $provider->create({
        user_id => 3,
        first_name => 'First3',
        last_name => 'Last3'
    });
    isa_ok($profile, 'Mango::Profile');
    is($profile->id, 3);
    is($profile->first_name, 'First3');
    is($profile->last_name, 'Last3');
    cmp_ok($profile->created->epoch, '>=', $current->epoch);
    is($provider->search->count, 3);
};


## create w/DateTime
## anything other than sqlite should barf at a bogus fk value
{
    my $current = DateTime->now;
    my $profile = $provider->create({
        user => 4,
        first_name => 'First4',
        last_name => 'Last4',
        created  => DateTime->now
    });
    isa_ok($profile, 'Mango::Profile');
    is($profile->id, 4);
    is($profile->first_name, 'First4');
    is($profile->last_name, 'Last4');
    cmp_ok($profile->created->epoch, '>=', $current->epoch);
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

    my $profile = Mango::Profile->new({
        data => {
            id => 4,
            first_name => 'UpdatedFirst4',
            last_name => 'UpdatedLast4',
            created  => $date
        }
    });

    ok($provider->update($profile));

    my $updated = $provider->get_by_id(4);    
    isa_ok($updated, 'Mango::Profile');
    is($updated->id, 4);
    is($profile->first_name, 'UpdatedFirst4');
    is($profile->last_name, 'UpdatedLast4');
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

    my $profile = Mango::Profile->new({
        provider => $provider,
        data => {
            id => 3,
            first_name => 'UpdatedFirst3',
            last_name => 'UpdatedLast3',
            created  => $date
        }
    });
    ok($profile->update);

    my $updated = $provider->get_by_id(3);
    isa_ok($updated, 'Mango::Profile');
    is($updated->id, 3);
    is($profile->first_name, 'UpdatedFirst3');
    is($profile->last_name, 'UpdatedLast3');
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
    my $profile = Mango::Profile->new({
        data => {
            id => 2
        }
    });
    ok($provider->delete($profile));
    is($provider->search->count, 1);
    is($provider->get_by_id(2), undef);
};


## delete on result object
{
    my $profile = Mango::Profile->new({
        provider => $provider,
        data => {
            id => 1
        }
    });
    ok($profile->destroy);
    is($provider->search->count, 0);
    is($provider->get_by_id(1), undef);
};


## create/delete using user object
{
    my $user = Mango::User->new({
        data => {
            id => 3
        }
    });

    my $profile = $provider->create({
        user => $user,
        first_name => 'First3',
        last_name => 'Last3'
    });
    isa_ok($profile, 'Mango::Profile');
    is($profile->user_id, 3);
    is($profile->first_name, 'First3');
    is($profile->last_name, 'Last3');
    is($provider->search->count, 1);

    $provider->delete({
        user => $user
    });
    is($provider->search->count, 0);
};


## create/delete using user object in hash as id
{
    my $user = Mango::User->new({
        data => {
            id => 4
        }
    });

    my $profile = $provider->create({
        user => $user,
        first_name => 'First4',
        last_name => 'Last4'
    });
    isa_ok($profile, 'Mango::Profile');
    is($profile->user_id, 4);
    is($profile->first_name, 'First4');
    is($profile->last_name, 'Last4');
    is($provider->search->count, 1);

    $provider->delete({
        user => $user->id
    });
    is($provider->search->count, 0);
};


## create throws exception when user isn't a user object
{
    try {
        local $ENV{'LANG'} = 'en';
        $provider->create({
            user => bless({}, 'Junk'),
            first_name => 'Christopher'
        });

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


## delete throws exception when user isn't a user object
{
    try {
        local $ENV{'LANG'} = 'en';
        $provider->delete({
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
