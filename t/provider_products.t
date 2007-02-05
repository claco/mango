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
        plan tests => 114;
    };

    use_ok('Mango::Provider::Products');
    use_ok('Mango::Product');
    use_ok('Mango::Currency');
    use_ok('Mango::Exception', ':try');
};

my $schema = Mango::Test->init_schema;
my $provider = Mango::Provider::Products->new({
    connection_info => [$schema->dsn]
});
isa_ok($provider, 'Mango::Provider::Products');


## get by id
{
    my $product = $provider->get_by_id(1);
    isa_ok($product, 'Mango::Product');
    is($product->id, 1);
    is($product->sku, 'SKU1111');
    is($product->name, 'SKU 1');
    is($product->description, 'My SKU 1');
    is($product->price, 1.11);
    isa_ok($product->price, 'Mango::Currency');
    is($product->created, '2004-07-04T12:00:00');
};


## get by id w/object
{
    my $object = Mango::Object->new({
       data => {id => 2} 
    });
    my $product = $provider->get_by_id($object);
    isa_ok($product, 'Mango::Product');
    is($product->id, 2);
    is($product->sku, 'SKU2222');
    is($product->name, 'SKU 2');
    is($product->description, 'My SKU 2');
    is($product->price, 2.22);
    is($product->created, '2004-07-04T12:00:00');
};


## get by id for nothing
{
    my $product = $provider->get_by_id(100);
    is($product, undef);
};


## get by user
{
    try {
        local $ENV{'LANG'} = 'en';
        $provider->get_by_user(2);

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/method not implemented/i);
    } otherwise {
        fail('Other exception thrown');
    };
};



## search w/iterator
{
    my $products = $provider->search;
    isa_ok($products, 'Mango::Iterator');
    is($products->count, 3);

    for (1..3) {
        my $product = $products->next;
        isa_ok($product, 'Mango::Product');
        is($product->id, $_);
        is($product->sku, "SKU$_$_$_$_");
        is($product->name, "SKU $_");
        is($product->description, "My SKU $_");
        is($product->created, '2004-07-04T12:00:00');
    };
};


## search as list
{
    my @products = $provider->search;
    is($#products, 2);

    for (1..3) {
        my $product = $products[$_-1];
        isa_ok($product, 'Mango::Product');
        is($product->id, $_);
        is($product->sku, "SKU$_$_$_$_");
        is($product->name, "SKU $_");
        is($product->description, "My SKU $_");
        is($product->created, '2004-07-04T12:00:00');
    };
};


## search w/filter
{
    my $products = $provider->search({name => 'SKU 2'});
    isa_ok($products, 'Mango::Iterator');
    is($products->count, 1);

    my $product = $products->next;
    isa_ok($product, 'Mango::Product');
    is($product->id, 2);
    is($product->sku, 'SKU2222');
    is($product->name, 'SKU 2');
    is($product->description, 'My SKU 2');
    is($product->price, 2.22);
    is($product->created, '2004-07-04T12:00:00');
};


## search for nothing
{
    my $products = $provider->search({name => 'foooz'});
    isa_ok($products, 'Mango::Iterator');
    is($products->count, 0);
};


## create
{
    my $current = DateTime->now;
    my $product = $provider->create({
        sku => 'SKU4444',
        name => 'SKU 4',
        description => 'My SKU 4',
        price => 4.44
    });
    isa_ok($product, 'Mango::Product');
    is($product->id, 4);
    is($product->sku, 'SKU4444');
    is($product->name, 'SKU 4');
    is($product->description, 'My SKU 4');
    is($product->price, Mango::Currency->new(4.44));
    cmp_ok($product->created->epoch, '>=', $current->epoch);
    is($provider->search->count, 4);
};


## create w/DateTime
{
    my $current = DateTime->now;
    my $product = $provider->create({
        sku => 'SKU5555',
        name => 'SKU 5',
        description => 'My SKU 5',
        created  => DateTime->now,
        price => 5.55
    });
    isa_ok($product, 'Mango::Product');
    is($product->id, 5);
    is($product->name, 'SKU 5');
    is($product->description, 'My SKU 5');
    is($product->price, 5.55);
    cmp_ok($product->created->epoch, '>=', $current->epoch);
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

    my $product = Mango::Product->new({
        data => {
            id => 4,
            name => 'updatedproduct4',
            description => 'UpdatedProduct4',
            created  => $date
        }
    });

    ok($provider->update($product));

    my $updated = $provider->get_by_id(4);    
    isa_ok($updated, 'Mango::Product');
    is($updated->id, 4);
    is($updated->name, 'updatedproduct4');
    is($updated->description, 'UpdatedProduct4');
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

    my $product = Mango::Product->new({
        provider => $provider,
        data => {
            id => 3,
            name => 'updatedproduct3',
            description => 'UpdatedProduct3',
            created  => $date
        }
    });
    ok($product->update);

    my $updated = $provider->get_by_id(3);
    isa_ok($updated, 'Mango::Product');
    is($updated->id, 3);
    is($updated->name, 'updatedproduct3');
    is($updated->description, 'UpdatedProduct3');
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
    my $product = Mango::Product->new({
        data => {
            id => 2
        }
    });
    ok($provider->delete($product));
    is($provider->search->count, 2);
    is($provider->get_by_id(2), undef);
};


## delete on result object
{
    my $product = Mango::Product->new({
        provider => $provider,
        data => {
            id => 1
        }
    });
    ok($product->destroy);
    is($provider->search->count, 1);
    is($provider->get_by_id(1), undef);
};
