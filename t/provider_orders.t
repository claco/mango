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
        plan tests => 136;
    };

    use_ok('Mango::Provider::Orders');
    use_ok('Mango::Exception', ':try');
    use_ok('Mango::Order');
    use_ok('Mango::User');
};

my $schema = Mango::Test->init_schema;
my $provider = Mango::Provider::Orders->new({
    connection_info => [$schema->dsn]
});
isa_ok($provider, 'Mango::Provider::Orders');


## get by id
{
    my $order = $provider->get_by_id(1);
    isa_ok($order, 'Mango::Order');
    is($order->id, 1);
    is($order->user_id, 1);
    is($order->created, '2004-07-04T12:00:00');
};


## get by id w/object
{
    my $object = Mango::Object->new({
       id => 2
    });
    my $order = $provider->get_by_id($object);
    isa_ok($order, 'Mango::Order');
    is($order->id, 2);
    is($order->user_id, 1);
    is($order->created, '2004-07-04T12:00:00');
};


## get by id for nothing
{
    my $order = $provider->get_by_id(100);
    is($order, undef);
};


## get by user
{
    my @orders = $provider->search({ user => 1 });
    is(scalar @orders, 2);
    my $order = $orders[0];
    isa_ok($order, 'Mango::Order');
    is($order->id, 1);
    is($order->user_id, 1);
    is($order->created, '2004-07-04T12:00:00');

    $order = $orders[1];
    isa_ok($order, 'Mango::Order');
    is($order->id, 2);
    is($order->user_id, 1);
    is($order->created, '2004-07-04T12:00:00');
};


## get by user w/ object
{
    my $user = Mango::User->new({
        id => 1
    });
    my @orders = $provider->search({ user => $user });
    is(scalar @orders, 2);
    my $order = $orders[0];
    isa_ok($order, 'Mango::Order');
    is($order->id, 1);
    is($order->user_id, 1);
    is($order->created, '2004-07-04T12:00:00');

    $order = $orders[1];
    isa_ok($order, 'Mango::Order');
    is($order->id, 2);
    is($order->user_id, 1);
    is($order->created, '2004-07-04T12:00:00');
};


## get by user for nothing
{
    my $orders = $provider->search({ user => 100 });
    isa_ok($orders, 'Mango::Iterator');
    is($orders->count, 0);
};


## search w/iterator
{
    my $orders = $provider->search;
    isa_ok($orders, 'Mango::Iterator');
    is($orders->count, 3);

    for (1..3) {
        my $order = $orders->next;
        isa_ok($order, 'Mango::Order');
        is($order->id, $_);
        if ($_ == 3) {
            is($order->user_id, 2);
        } else {
            is($order->user_id, 1);
        };
        is($order->created, '2004-07-04T12:00:00');
    };
};


## search as list
{
    my @orders = $provider->search;
    is($#orders, 2);

    for (1..3) {
        my $order = $orders[$_-1];
        isa_ok($order, 'Mango::Order');
        is($order->id, $_);
        if ($_ == 3) {
            is($order->user_id, 2);
        } else {
            is($order->user_id, 1);
        };
        is($order->created, '2004-07-04T12:00:00');
    };
};


## search w/filter
{
    my $orders = $provider->search({created => {'<=', DateTime->now}});
    isa_ok($orders, 'Mango::Iterator');
    is($orders->count, 3);

    my $order = $orders->next;
    isa_ok($order, 'Mango::Order');
    is($order->id, 1);
    is($order->user_id, 1);
    is($order->created, '2004-07-04T12:00:00');

    $order = $orders->next;
    isa_ok($order, 'Mango::Order');
    is($order->id, 2);
    is($order->user_id, 1);
    is($order->created, '2004-07-04T12:00:00');

    $order = $orders->next;
    isa_ok($order, 'Mango::Order');
    is($order->id, 3);
    is($order->user_id, 2);
    is($order->created, '2004-07-04T12:00:00');
};


## search for nothing
{
    my $orders = $provider->search({id => 100});
    isa_ok($orders, 'Mango::Iterator');
    is($orders->count, 0);
};


## create
{
    my $user = Mango::User->new({
        id => 3
    });
    my $current = DateTime->now;
    my $order = $provider->create({
        user => $user
    });
    isa_ok($order, 'Mango::Order');
    is($order->id, 4);
    is($order->user_id, 3);
    cmp_ok($order->created->epoch, '>=', $current->epoch);
    is($provider->search->count, 4);
};


## create w/DateTime
{
    my $current = DateTime->now;
    my $order = $provider->create({
        user => 1,
        created => DateTime->now
    });
    isa_ok($order, 'Mango::Order');
    is($order->id, 5);
    is($order->user_id, 1);
    cmp_ok($order->created->epoch, '>=', $current->epoch);
    is($provider->search->count, 5);
};


## create w/key
{
    my $current = DateTime->now;
    my $order = $provider->create({
        user_id => 1
    });
    isa_ok($order, 'Mango::Order');
    is($order->id, 6);
    is($order->user_id, 1);
    cmp_ok($order->created->epoch, '>=', $current->epoch);

    $order->destroy;
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

    my $order = $provider->get_by_id(4);
    $order->autoupdate(0);
    $order->update({
        user_id => 1,
        created  => $date
    });

    ok($provider->update($order));

    my $updated = $provider->get_by_id(4);    
    isa_ok($updated, 'Mango::Order');
    is($updated->id, 4);
    is($order->user_id, 1);
    cmp_ok($updated->created->epoch, '=', $date->epoch);
    is($provider->search->count, 5);

    is($order->count, 0);
    my $item = $order->add({
        sku => 'ABC-123'
    });
    is($order->count, 1);
    $item->sku('FOO');
    $item->update;

    is($order->items->first->sku, 'FOO');
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

    my $order = $provider->get_by_id(3);
    $order->autoupdate(0);
    $order->user_id(2);
    $order->created($date);
    ok($order->update);

    my $updated = $provider->get_by_id(3);
    isa_ok($updated, 'Mango::Order');
    is($updated->id, 3);
    is($order->user_id, 2);
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
    my $order = $provider->get_by_id(2);
    ok($provider->delete($order));
    is($provider->search->count, 2);
    is($provider->get_by_id(2), undef);
};


## delete on result object
{
    my $order = $provider->get_by_id(1);
    ok($order->destroy);
    is($provider->search->count, 1);
    is($provider->get_by_id(1), undef);
};


## delete using user id
{
    is($provider->search->count, 1);
    $provider->create({
        user => 23
    });
    is($provider->search->count, 2);
    ok($provider->delete({
        user => 23
    }));
    is($provider->search->count, 1);
};


## delete using user object
{
    my $user = Mango::User->new({
        id => 24
    });
    is($provider->search->count, 1);
    $provider->create({
        user => $user
    });
    is($provider->search->count, 2);
    ok($provider->delete({
        user => $user
    }));
    is($provider->search->count, 1);
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


## delete throws exception when order isn't a order object
{
    try {
        local $ENV{'LANG'} = 'en';
        $provider->delete(bless({}, 'Junk'));

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/not a Mango::Order/i, 'not a Mango::Order');
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
