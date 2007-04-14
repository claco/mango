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
        plan tests => 90;
    };

    use_ok('Mango::Provider::Carts');
    use_ok('Mango::Cart');
    use_ok('Mango::User');
};

my $schema = Mango::Test->init_schema;
my $provider = Mango::Provider::Carts->new({
    connection_info => [$schema->dsn]
});
isa_ok($provider, 'Mango::Provider::Carts');


## get by id
{
    my $cart = $provider->get_by_id(1);
    isa_ok($cart, 'Mango::Cart');
    is($cart->id, 1);
    is($cart->user_id, 1);
    is($cart->created, '2004-07-04T12:00:00');
};


## get by id w/object
{
    my $object = Mango::Object->new({
       data => {id => 2} 
    });
    my $cart = $provider->get_by_id($object);
    isa_ok($cart, 'Mango::Cart');
    is($cart->id, 2);
    is($cart->user_id, undef);
    is($cart->created, '2004-07-04T12:00:00');
};


## get by id for nothing
{
    my $cart = $provider->get_by_id(100);
    is($cart, undef);
};


## get by user
{
    my @carts = $provider->search({ user => 1 });
    is(scalar @carts, 1);
    my $cart = $carts[0];
    isa_ok($cart, 'Mango::Cart');
    is($cart->id, 1);
    is($cart->user_id, 1);
    is($cart->created, '2004-07-04T12:00:00');
};


## get by user w/ object
{
    my $user = Mango::User->new({
        data => {
            id => 1
        }
    });
    my @carts = $provider->search({ user => $user });
    is(scalar @carts, 1);
    my $cart = $carts[0];
    isa_ok($cart, 'Mango::Cart');
    is($cart->id, 1);
    is($cart->user_id, 1);
    is($cart->created, '2004-07-04T12:00:00');
};


## get by user for nothing
{
    my $carts = $provider->search({ user => 100 });
    isa_ok($carts, 'Mango::Iterator');
    is($carts->count, 0);
};


## search w/iterator
{
    my $carts = $provider->search;
    isa_ok($carts, 'Mango::Iterator');
    is($carts->count, 2);

    for (1..2) {
        my $cart = $carts->next;
        isa_ok($cart, 'Mango::Cart');
        is($cart->id, $_);
        if ($_ == 2) {
            is($cart->user_id, undef);
        } else {
            is($cart->user_id, 1);
        };
        is($cart->created, '2004-07-04T12:00:00');
    };
};


## search as list
{
    my @carts = $provider->search;
    is($#carts, 1);

    for (1..2) {
        my $cart = $carts[$_-1];
        isa_ok($cart, 'Mango::Cart');
        is($cart->id, $_);
        if ($_ == 2) {
            is($cart->user_id, undef);
        } else {
            is($cart->user_id, 1);
        };
        is($cart->created, '2004-07-04T12:00:00');
    };
};


## search w/filter
{
    my $carts = $provider->search({created => {'<=', DateTime->now}});
    isa_ok($carts, 'Mango::Iterator');
    is($carts->count, 2);

    my $cart = $carts->next;
    isa_ok($cart, 'Mango::Cart');
    is($cart->id, 1);
    is($cart->user_id, 1);
    is($cart->created, '2004-07-04T12:00:00');

    $cart = $carts->next;
    isa_ok($cart, 'Mango::Cart');
    is($cart->id, 2);
    is($cart->user_id, undef);
    is($cart->created, '2004-07-04T12:00:00');
};


## search for nothing
{
    my $carts = $provider->search({id => 100});
    isa_ok($carts, 'Mango::Iterator');
    is($carts->count, 0);
};


## create
{
    my $current = DateTime->now;
    my $cart = $provider->create;
    isa_ok($cart, 'Mango::Cart');
    is($cart->id, 3);
    is($cart->user_id, undef);
    cmp_ok($cart->created->epoch, '>=', $current->epoch);
    is($provider->search->count, 3);
};


## create w/DateTime
{
    my $current = DateTime->now;
    my $cart = $provider->create({
        user_id => 1,
        created  => DateTime->now
    });
    isa_ok($cart, 'Mango::Cart');
    is($cart->id, 4);
    is($cart->user_id, 1);
    cmp_ok($cart->created->epoch, '>=', $current->epoch);
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

    my $cart = $provider->get_by_id(4);
    $cart->autoupdate(0);
    $cart->update({
        user_id => undef,
        created  => $date
    });

    ok($provider->update($cart));

    my $updated = $provider->get_by_id(4);    
    isa_ok($updated, 'Mango::Cart');
    is($updated->id, 4);
    is($cart->user_id, undef);
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

    my $cart = $provider->get_by_id(3);
    $cart->autoupdate(0);
    $cart->user_id(undef);
    $cart->created($date);
    ok($cart->update);

    my $updated = $provider->get_by_id(3);
    isa_ok($updated, 'Mango::Cart');
    is($updated->id, 3);
    is($cart->user_id, undef);
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
    my $cart = $provider->get_by_id(2);
    ok($provider->delete($cart));
    is($provider->search->count, 1);
    is($provider->get_by_id(2), undef);
};


## delete on result object
{
    my $cart = $provider->get_by_id(1);
    ok($cart->destroy);
    is($provider->search->count, 0);
    is($provider->get_by_id(1), undef);
};
