#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Test::More;
    use Mango::Test ();

    eval 'require DBD::SQLite';
    if($@) {
        plan skip_all => 'DBD::SQLite not installed';
    } else {
        plan tests => 150;
    };

    use_ok('Mango::Provider::Wishlists');
    use_ok('Mango::Exception', ':try');
    use_ok('Mango::Wishlist');
    use_ok('Mango::User');
};

my $schema = Mango::Test->init_schema;
my $provider = Mango::Provider::Wishlists->new({
    #connection_info => [$schema->dsn]
});
## use faster test schema
$provider->storage->storage->schema_instance($schema);
isa_ok($provider, 'Mango::Provider::Wishlists');


## get by id
{
    my $wishlist = $provider->get_by_id(1);
    isa_ok($wishlist, 'Mango::Wishlist');
    is($wishlist->id, 1);
    is($wishlist->user_id, 1);
    is($wishlist->name, 'Wishlist1');
    is($wishlist->description, 'First Wishlist');
    is($wishlist->created, '2004-07-04T12:00:00');
};


## get by id w/object
{
    my $object = Mango::Object->new({
       id => 2
    });
    my $wishlist = $provider->get_by_id($object);
    isa_ok($wishlist, 'Mango::Wishlist');
    is($wishlist->id, 2);
    is($wishlist->user_id, 1);
    is($wishlist->name, 'Wishlist2');
    is($wishlist->description, 'Second Wishlist');
    is($wishlist->created, '2004-07-04T12:00:00');
};


## get by id for nothing
{
    my $wishlist = $provider->get_by_id(100);
    is($wishlist, undef);
};


## get by user
{
    my @wishlists = $provider->search({ user => 1 });
    is(scalar @wishlists, 2);
    my $wishlist = $wishlists[0];
    isa_ok($wishlist, 'Mango::Wishlist');
    is($wishlist->id, 1);
    is($wishlist->user_id, 1);
    is($wishlist->name, 'Wishlist1');
    is($wishlist->description, 'First Wishlist');
    is($wishlist->created, '2004-07-04T12:00:00');
};


## get by user w/ object
{
    my $user = Mango::User->new({
        id => 2
    });
    my @wishlists = $provider->search({ user => $user });
    is(scalar @wishlists, 1);
    my $wishlist = $wishlists[0];
    isa_ok($wishlist, 'Mango::Wishlist');
    is($wishlist->id, 3);
    is($wishlist->user_id, 2);
    is($wishlist->name, 'Wishlist3');
    is($wishlist->description, 'Third Wishlist');
    is($wishlist->created, '2004-07-04T12:00:00');
};


## get by user for nothing
{
    my $wishlists = $provider->search({ user => 100 });
    isa_ok($wishlists, 'Mango::Iterator');
    is($wishlists->count, 0);
};


## search w/iterator
{
    my $wishlists = $provider->search;
    isa_ok($wishlists, 'Mango::Iterator');
    is($wishlists->count, 3);

    for (1..3) {
        my $wishlist = $wishlists->next;
        isa_ok($wishlist, 'Mango::Wishlist');
        is($wishlist->id, $_);
        is($wishlist->name, "Wishlist$_");
        is($wishlist->created, '2004-07-04T12:00:00');
    };
};


## search as list
{
    my @wishlists = $provider->search;
    is($#wishlists, 2);

    for (1..3) {
        my $wishlist = $wishlists[$_-1];
        isa_ok($wishlist, 'Mango::Wishlist');
        is($wishlist->id, $_);
        is($wishlist->name, "Wishlist$_");
        is($wishlist->created, '2004-07-04T12:00:00');
    };
};


## search w/filter
{
    my $wishlists = $provider->search({created => {'<=', DateTime->now}});
    isa_ok($wishlists, 'Mango::Iterator');
    is($wishlists->count, 3);

    my $wishlist = $wishlists->next;
    isa_ok($wishlist, 'Mango::Wishlist');
    is($wishlist->id, 1);
    is($wishlist->user_id, 1);
    is($wishlist->name, 'Wishlist1');
    is($wishlist->description, 'First Wishlist');
    is($wishlist->created, '2004-07-04T12:00:00');

    $wishlist = $wishlists->next;
    isa_ok($wishlist, 'Mango::Wishlist');
    is($wishlist->id, 2);
    is($wishlist->user_id, 1);
    is($wishlist->name, 'Wishlist2');
    is($wishlist->description, 'Second Wishlist');
    is($wishlist->created, '2004-07-04T12:00:00');

    $wishlist = $wishlists->next;
    isa_ok($wishlist, 'Mango::Wishlist');
    is($wishlist->id, 3);
    is($wishlist->user_id, 2);
    is($wishlist->name, 'Wishlist3');
    is($wishlist->description, 'Third Wishlist');
    is($wishlist->created, '2004-07-04T12:00:00');
};


## search for nothing
{
    my $wishlists = $provider->search({id => 100});
    isa_ok($wishlists, 'Mango::Iterator');
    is($wishlists->count, 0);
};


## create
{
    my $current = DateTime->now;
    my $wishlist = $provider->create({
        user_id => 2,
        name => 'Wishlist4'
    });
    isa_ok($wishlist, 'Mango::Wishlist');
    is($wishlist->id, 4);
    is($wishlist->user_id, 2);
    is($wishlist->name, 'Wishlist4');
    is($wishlist->description, undef);
    cmp_ok($wishlist->created->epoch, '>=', $current->epoch);
    is($provider->search->count, 4);
};


## create w/DateTime
{
    my $current = DateTime->now;
    my $wishlist = $provider->create({
        user_id => 1,
        name => 'Wishlist5',
        description => 'Fifth Wishlist',
        created  => DateTime->now
    });
    isa_ok($wishlist, 'Mango::Wishlist');
    is($wishlist->id, 5);
    is($wishlist->user_id, 1);
    is($wishlist->name, 'Wishlist5');
    is($wishlist->description, 'Fifth Wishlist');
    cmp_ok($wishlist->created->epoch, '>=', $current->epoch);
    is($provider->search->count, 5);
};


## create with user object
{
    my $user = Mango::User->new({
        id => 23
    });
    my $current = DateTime->now;
    my $wishlist = $provider->create({
        user => $user,
        name => 'Wishlist23',
        created  => DateTime->now
    });
    isa_ok($wishlist, 'Mango::Wishlist');
    is($wishlist->id, 6);
    is($wishlist->user_id, 23);
    cmp_ok($wishlist->created->epoch, '>=', $current->epoch);
    is($provider->search->count, 6);

    my $item = $wishlist->add({
        sku => 'ABC-123'
    });
    $item->sku('FOO');
    $item->update;
    is($wishlist->items->first->sku, 'FOO');

    $provider->delete({
        user => 23
    });
};


## create with user id
{
    my $current = DateTime->now;
    my $wishlist = $provider->create({
        user => 24,
        name => 'Wishlist24',
        created  => DateTime->now
    });
    isa_ok($wishlist, 'Mango::Wishlist');
    is($wishlist->id, 6);
    is($wishlist->user_id, 24);
    cmp_ok($wishlist->created->epoch, '>=', $current->epoch);
    is($provider->search->count, 6);

    $provider->delete({
        user => Mango::User->new({id => 24})
    });
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

    my $wishlist = $provider->get_by_id(4);
    $wishlist->autoupdate(0);
    $wishlist->update({
        user_id => 1,
        created  => $date
    });

    ok($provider->update($wishlist));

    my $updated = $provider->get_by_id(4);    
    isa_ok($updated, 'Mango::Wishlist');
    is($updated->id, 4);
    is($wishlist->user_id, 1);
    is($wishlist->name, 'Wishlist4');
    is($wishlist->description, undef);
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

    my $wishlist = $provider->get_by_id(3);
    $wishlist->autoupdate(0);
    $wishlist->user_id(1);
    $wishlist->created($date);
    ok($wishlist->update);

    my $updated = $provider->get_by_id(3);
    isa_ok($updated, 'Mango::Wishlist');
    is($updated->id, 3);
    is($wishlist->user_id, 1);
    is($wishlist->name, 'Wishlist3');
    is($wishlist->description, 'Third Wishlist');
    cmp_ok($updated->created->epoch, '=', $date->epoch);
    is($provider->search->count, 5);
};


## delete using id
{
    ok($provider->delete(4));
    is($provider->search->count, 4);
    is($provider->get_by_id(4), undef);
};


## delete using hash
{
    ok($provider->delete({id => 3}));
    is($provider->search->count, 3);
    is($provider->get_by_id(3), undef);
};


## delete using object
{
    my $wishlist = $provider->get_by_id(2);
    ok($provider->delete($wishlist));
    is($provider->search->count, 2);
    is($provider->get_by_id(2), undef);
};


## delete on result object
{
    my $wishlist = $provider->get_by_id(1);
    ok($wishlist->destroy);
    is($provider->search->count, 1);
    is($provider->get_by_id(1), undef);
};


## create throws exception when user isn't a user object
{
    try {
        local $ENV{'LANG'} = 'en';
        $provider->create({
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


## create throws exception when user isn't a user object
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


## delete throws exception when cart isn't a cart object
{
    try {
        local $ENV{'LANG'} = 'en';
        $provider->delete(bless({}, 'Junk'));

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/not a Mango::Wishlist/i, 'not a Mango::Wishlist');
    } otherwise {
        fail('Other exception thrown');
    };
};


## create without data/user goes boom
{
    try {
        local $ENV{'LANG'} = 'en';
        $provider->create;

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/no user was specified/i, 'no user specified');
    } otherwise {
        fail('Other exception thrown');
    };
};


## wishlist type not implemented
{
    my $wishlist = $provider->create({
        user => 1, name => 'Wishlist1'
    });
    try {
        local $ENV{'LANG'} = 'en';
        $wishlist->type;

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/not implemented/i, 'not implemented');
    } otherwise {
        fail('Other exception thrown');
    };
};


## wishlist save not implemented
{
    my $wishlist = $provider->create({
        user => 1, name => 'Wishlist1'
    });
    try {
        local $ENV{'LANG'} = 'en';
        $wishlist->save;

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/not implemented/i, 'not implemented');
    } otherwise {
        fail('Other exception thrown');
    };
};
