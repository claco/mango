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
        plan tests => 382
    };

    use_ok('Mango::Provider::Products');
    use_ok('Mango::Product');
    use_ok('Mango::Attribute');
    use_ok('Mango::Tag');
    use_ok('Mango::Currency');
    use_ok('Mango::Exception', ':try');
};

my $schema = Mango::Test->init_schema;
my $provider = Mango::Provider::Products->new({
    #connection_info => [$schema->dsn]
    #use faster test schema
    schema => $schema
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
    is($product->price+0, 1.11);
    isa_ok($product->price, 'Mango::Currency');
    is($product->created, '2004-07-04T12:00:00');
};


## get by id w/object
{
    my $object = Mango::Object->new({
       id => 2
    });
    my $product = $provider->get_by_id($object);
    isa_ok($product, 'Mango::Product');
    is($product->id, 2);
    is($product->sku, 'SKU2222');
    is($product->name, 'SKU 2');
    is($product->description, 'My SKU 2');
    is($product->price+0, 2.22);
    is($product->created, '2004-07-04T12:00:00');
};


## get by id for nothing
{
    my $product = $provider->get_by_id(100);
    is($product, undef);
};


## get by sku
{
    my $product = $provider->get_by_sku('SKU2222');
    isa_ok($product, 'Mango::Product');
    is($product->id, 2);
    is($product->sku, 'SKU2222');
    is($product->name, 'SKU 2');
    is($product->description, 'My SKU 2');
    is($product->price+0, 2.22);
    is($product->created, '2004-07-04T12:00:00');
};


## get by sku for nothing
{
    my $product = $provider->get_by_sku('BOGUS');
    is($product, undef);
};


## search with tags
{
    my $tag2 = Mango::Tag->new({
        name => 'Tag2'
    });
    my $products = $provider->search({
        tags => [qw/Tag1/, $tag2]
    });
    isa_ok($products, 'Mango::Iterator');
    is($products->count, 1);

    my $product = $products->next;
    is($product->id, 1);
    is($product->sku, 'SKU1111');
    is($product->name, 'SKU 1');
    is($product->description, 'My SKU 1');
    is($product->price+0, 1.11);
    is($product->created, '2004-07-04T12:00:00');
};


## search with tags with existing join as array
{
    my $products = $provider->search({
        tags => [qw/Tag1 Tag2/]
    }, {
        join => ['attributes']
    });
    isa_ok($products, 'Mango::Iterator');
    is($products->count, 1);

    my $product = $products->next;
    is($product->id, 1);
    is($product->sku, 'SKU1111');
    is($product->name, 'SKU 1');
    is($product->description, 'My SKU 1');
    is($product->price+0, 1.11);
    is($product->created, '2004-07-04T12:00:00');
};


## search with tags with existing join as string
{
    my $products = $provider->search({
        tags => [qw/Tag1 Tag2/]
    }, {
        join => 'attributes'
    });
    isa_ok($products, 'Mango::Iterator');
    is($products->count, 1);

    my $product = $products->next;
    is($product->id, 1);
    is($product->sku, 'SKU1111');
    is($product->name, 'SKU 1');
    is($product->description, 'My SKU 1');
    is($product->price+0, 1.11);
    is($product->created, '2004-07-04T12:00:00');
};


## search with tags with existing join as hash
{
    my $products = $provider->search({
        tags => [qw/Tag1 Tag2/]
    }, {
        join => {'map_product_tag' => 'tag'}
    });
    isa_ok($products, 'Mango::Iterator');
    is($products->count, 1);

    my $product = $products->next;
    is($product->id, 1);
    is($product->sku, 'SKU1111');
    is($product->name, 'SKU 1');
    is($product->description, 'My SKU 1');
    is($product->price+0, 1.11);
    is($product->created, '2004-07-04T12:00:00');
};


## search for tags for no matches
{
    my $products = $provider->search({
        tags => [qw/Tag1 Tag2 Tag3/]
    });
    isa_ok($products, 'Mango::Iterator');
    is($products->count, 0);
};


## search for tags with no tags
{
    my $products = $provider->search({
        tags => []
    }, {
        order_by => 'id desc'
    });
    isa_ok($products, 'Mango::Iterator');
    is($products->count, 3);

    my $product = $products->next;
    is($product->id, 3);
    is($product->sku, 'SKU3333');
    is($product->name, 'SKU 3');
    is($product->description, 'My SKU 3');
    is($product->price+0, 3.33);
    is($product->created, '2004-07-04T12:00:00');

    $product = $products->next;
    is($product->id, 2);
    is($product->sku, 'SKU2222');
    is($product->name, 'SKU 2');
    is($product->description, 'My SKU 2');
    is($product->price+0, 2.22);
    is($product->created, '2004-07-04T12:00:00');

    $product = $products->next;
    is($product->id, 1);
    is($product->sku, 'SKU1111');
    is($product->name, 'SKU 1');
    is($product->description, 'My SKU 1');
    is($product->price+0, 1.11);
    is($product->created, '2004-07-04T12:00:00');
};


## search with tags and other filters
{
    my $products = $provider->search({
        tags => [qw/Tag3/],
        sku  => 'SKU3333'
    });
    isa_ok($products, 'Mango::Iterator');
    is($products->count, 1);

    my $product = $products->next;
    is($product->id, 3);
    is($product->sku, 'SKU3333');
    is($product->name, 'SKU 3');
    is($product->description, 'My SKU 3');
    is($product->price+0, 3.33);
    is($product->created, '2004-07-04T12:00:00');
};


## search with tags and other filters with no match
{
    my $products = $provider->search({
        tags => [qw/Tag3/],
        sku  => 'BOGUSSKU'
    });
    isa_ok($products, 'Mango::Iterator');
    is($products->count, 0);
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
    is($product->price+0, 2.22);
    is($product->created, '2004-07-04T12:00:00');
};


## search for nothing
{
    my $products = $provider->search({name => 'foooz'});
    isa_ok($products, 'Mango::Iterator');
    is($products->count, 0);
};


## search for attributes
{
    my $product = Mango::Product->new({
        id => 1
    });

    my $attributes = $provider->search_attributes($product->id, undef, {
        order_by => 'id desc'
    });
    isa_ok($attributes, 'Mango::Iterator');
    is($attributes->count, 2);
    is($attributes->pager, undef);

    my $attribute = $attributes->next;
    isa_ok($attribute, 'Mango::Attribute');
    is($attribute->id, 2);
    is($attribute->name, 'Attribute2');
    is($attribute->value, 'Value2');
    is($attribute->created, '2004-07-04T12:00:00');

    $attribute = $attributes->next;
    isa_ok($attribute, 'Mango::Attribute');
    is($attribute->id, 1);
    is($attribute->name, 'Attribute1');
    is($attribute->value, 'Value1');
    is($attribute->created, '2004-07-04T12:00:00');
};


## search for attributes w/filter
{
    my $product = Mango::Product->new({
        id => 1
    });

    my $attributes = $provider->search_attributes($product, {name => 'Attribute2'}, {
        page => 1, rows => 1
    });
    isa_ok($attributes, 'Mango::Iterator');
    is($attributes->count, 1);
    isa_ok($attributes->pager, 'Data::Page');

    my $attribute = $attributes->next;
    isa_ok($attribute, 'Mango::Attribute');
    is($attribute->id, 2);
    is($attribute->name, 'Attribute2');
    is($attribute->value, 'Value2');
    is($attribute->created, '2004-07-04T12:00:00');
};


## search for attributes w/filter return list
{
    my $product = Mango::Product->new({
        id => 1
    });

    my @attributes = $provider->search_attributes($product, {name => 'Attribute2'});
    is(scalar @attributes, 1);

    my $attribute = shift @attributes;
    isa_ok($attribute, 'Mango::Attribute');
    is($attribute->id, 2);
    is($attribute->name, 'Attribute2');
    is($attribute->value, 'Value2');
    is($attribute->created, '2004-07-04T12:00:00');
};


## search for attributes w/ nothing
{
    my $product = Mango::Product->new({
        id => 233
    });

    my $attributes = $provider->search_attributes($product, {name => 'Attribute2'});
    isa_ok($attributes, 'Mango::Iterator');
    is($attributes->count, 0);
};


## search for tags
{
    my $product = Mango::Product->new({
        id => 1
    });

    my $tags = $provider->search_tags($product->id, undef, {
        order_by => 'tag.id desc'
    });
    isa_ok($tags, 'Mango::Iterator');
    is($tags->count, 2);

    my $tag = $tags->next;
    isa_ok($tag, 'Mango::Tag');
    is($tag->id, 2);
    is($tag->name, 'Tag2');
    is($tag->created, '2004-07-04T12:00:00');
    is($tag->count, 1);

    $tag = $tags->next;
    isa_ok($tag, 'Mango::Tag');
    is($tag->id, 1);
    is($tag->name, 'Tag1');
    is($tag->created, '2004-07-04T12:00:00');
    is($tag->count, 1);
};


## search for tags w/filter
{
    my $product = Mango::Product->new({
        id => 1
    });

    my $tags = $provider->search_tags($product, {name => 'Tag2'});
    isa_ok($tags, 'Mango::Iterator');
    is($tags->count, 1);

    my $tag = $tags->next;
    isa_ok($tag, 'Mango::Tag');
    is($tag->id, 2);
    is($tag->name, 'Tag2');
    is($tag->created, '2004-07-04T12:00:00');
};


## search for tags w/ nothing
{
    my $product = Mango::Product->new({
        id => 233
    });

    my $tags = $provider->search_tags($product, {name => 'Tag1'});
    isa_ok($tags, 'Mango::Iterator');
    is($tags->count, 0);
};


## search all tags assigned to products
{
    my $tags = $provider->tags;
    isa_ok($tags, 'Mango::Iterator');
    is($tags->count, 3);

    my $tag = $tags->next;
    isa_ok($tag, 'Mango::Tag');
    is($tag->name, 'Tag1');

    $tag = $tags->next;
    isa_ok($tag, 'Mango::Tag');
    is($tag->name, 'Tag2');

    $tag = $tags->next;
    isa_ok($tag, 'Mango::Tag');
    is($tag->name, 'Tag3');
};


## search all tags assigned to products with filter
{
    my $tags = $provider->tags({
        'tag.name' => 'Tag2'
    });
    isa_ok($tags, 'Mango::Iterator');
    is($tags->count, 1);

    my $tag = $tags->next;
    isa_ok($tag, 'Mango::Tag');
    is($tag->name, 'Tag2');
};


## search all tags assigned to products with filter as list
{
    my @tags = $provider->tags({
        name => 'Tag2'
    });
    is(scalar @tags, 1);

    my $tag = shift @tags;
    isa_ok($tag, 'Mango::Tag');
    is($tag->name, 'Tag2');
};


## search all tags assigned to products with filter using me. and products key
{
    my $tags = $provider->tags({
        name => 'Tag2',
        products => {
            'me.id' => 1
        }
    });
    isa_ok($tags, 'Mango::Iterator');
    is($tags->count, 1);

    my $tag = $tags->next;
    isa_ok($tag, 'Mango::Tag');
    is($tag->name, 'Tag2');
};


## create
{
    my $current = DateTime->now;
    my $product = $provider->create({
        sku => 'SKU4444',
        name => 'SKU 4',
        description => 'My SKU 4',
        price => 4.44,
        attributes => [
            {name => 'CreatedAttribute1', value => 'CreatedValue1'},
            {name => 'CreatedAttribute2', value => 'CreatedValue2'},
            Mango::Attribute->new({
                name => 'CreatedAttribute3', value => 'CreatedValue3'
            })
        ],
        tags => [
            'CreatedTag1',
            'Tag2',
            'Tag2',
            {name => 'CreatedTag2'},
            Mango::Tag->new({
                name => 'CreatedTag3'
            })
        ]
    });
    isa_ok($product, 'Mango::Product');
    is($product->id, 4);
    is($product->sku, 'SKU4444');
    is($product->name, 'SKU 4');
    is($product->description, 'My SKU 4');
    is($product->price, Mango::Currency->new(4.44));
    cmp_ok($product->created->epoch, '>=', $current->epoch);

    my $attributes = $product->attributes;
    isa_ok($attributes, 'Mango::Iterator');
    is($attributes->count, 3);

    my $attribute = $attributes->next;
    isa_ok($attribute, 'Mango::Attribute');
    is($attribute->{'product_id'}, 4);
    is($attribute->name, 'CreatedAttribute1');
    is($attribute->value, 'CreatedValue1');
    cmp_ok($attribute->created->epoch, '>=', $current->epoch);

    $attribute = $attributes->next;
    isa_ok($attribute, 'Mango::Attribute');
    is($attribute->{'product_id'}, 4);
    is($attribute->name, 'CreatedAttribute2');
    is($attribute->value, 'CreatedValue2');
    cmp_ok($attribute->created->epoch, '>=', $current->epoch);

    $attribute = $attributes->next;
    isa_ok($attribute, 'Mango::Attribute');
    is($attribute->{'product_id'}, 4);
    is($attribute->name, 'CreatedAttribute3');
    is($attribute->value, 'CreatedValue3');
    cmp_ok($attribute->created->epoch, '>=', $current->epoch);

    my $tags = $product->tags;
    isa_ok($tags, 'Mango::Iterator');
    is($tags->count, 4);

    my $tag = $tags->next;
    isa_ok($tag, 'Mango::Tag');
    is($tag->name, 'Tag2');

    $tag = $tags->next;
    isa_ok($tag, 'Mango::Tag');
    is($tag->name, 'CreatedTag1');
    cmp_ok($tag->created->epoch, '>=', $current->epoch);

    $tag = $tags->next;
    isa_ok($tag, 'Mango::Tag');
    is($tag->name, 'CreatedTag2');
    cmp_ok($tag->created->epoch, '>=', $current->epoch);

    $tag = $tags->next;
    isa_ok($tag, 'Mango::Tag');
    is($tag->name, 'CreatedTag3');
    cmp_ok($tag->created->epoch, '>=', $current->epoch);

    ok($product->delete_attributes({
        name => [qw/CreatedAttribute1 CreatedAttribute2/]
    }));
    $attributes = $product->attributes;
    isa_ok($attributes, 'Mango::Iterator');
    is($attributes->count, 1);

    $attribute = $attributes->next;
    isa_ok($attribute, 'Mango::Attribute');
    is($attribute->{'product_id'}, 4);
    is($attribute->name, 'CreatedAttribute3');
    is($attribute->value, 'CreatedValue3');
    cmp_ok($attribute->created->epoch, '>=', $current->epoch);
    ok($attribute->destroy);

    $attributes = $product->attributes;
    isa_ok($attributes, 'Mango::Iterator');
    is($attributes->count, 0);

    ok($product->delete_tags({
        name => [qw/CreatedTag1/]
    }));
    ok($provider->delete_tags($product->id, {name => 'CreatedTag3'}));
    $tags = $product->tags;
    isa_ok($tags, 'Mango::Iterator');
    is($tags->count, 2);

    $tag = $tags->next;
    isa_ok($tag, 'Mango::Tag');
    is($tag->name, 'Tag2');

    $tag = $tags->next;
    isa_ok($tag, 'Mango::Tag');
    is($tag->name, 'CreatedTag2');
    cmp_ok($tag->created->epoch, '>=', $current->epoch);

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
    is($product->price+0, 5.55);
    cmp_ok($product->created->epoch, '>=', $current->epoch);

    my $attribute = $provider->add_attribute($product->id, {
        name => 'CreatedAttribute1', value => 'CreatedValue1'
    });
    isa_ok($attribute, 'Mango::Attribute');
    is($attribute->name, 'CreatedAttribute1');
    is($attribute->value, 'CreatedValue1');

    my $attributes = $product->attributes;
    isa_ok($attributes, 'Mango::Iterator');
    is($attributes->count, 1);

    $attribute = $attributes->next;
    isa_ok($attribute, 'Mango::Attribute');
    is($attribute->{'product_id'}, 5);
    is($attribute->name, 'CreatedAttribute1');
    is($attribute->value, 'CreatedValue1');
    cmp_ok($attribute->created->epoch, '>=', $current->epoch);

    my @attributes = $product->add_attributes(
        {name => 'CreatedAttribute2', value => 'CreatedValue2'},
        Mango::Attribute->new({
            name => 'CreatedAttribute3', value => 'CreatedValue3'
        })
    );
    is(scalar @attributes, 2);

    $attribute = $attributes[0];
    isa_ok($attribute, 'Mango::Attribute');
    is($attribute->{'product_id'}, 5);
    is($attribute->name, 'CreatedAttribute2');
    is($attribute->value, 'CreatedValue2');
    cmp_ok($attribute->created->epoch, '>=', $current->epoch);

    $attribute = $attributes[1];
    isa_ok($attribute, 'Mango::Attribute');
    is($attribute->{'product_id'}, 5);
    is($attribute->name, 'CreatedAttribute3');
    is($attribute->value, 'CreatedValue3');
    cmp_ok($attribute->created->epoch, '>=', $current->epoch);

    $attributes = $product->attributes;
    isa_ok($attributes, 'Mango::Iterator');
    is($attributes->count, 3);

    $attribute = $attributes->next;
    isa_ok($attribute, 'Mango::Attribute');
    is($attribute->{'product_id'}, 5);
    is($attribute->name, 'CreatedAttribute1');
    is($attribute->value, 'CreatedValue1');
    cmp_ok($attribute->created->epoch, '>=', $current->epoch);

    $attribute = $attributes->next;
    isa_ok($attribute, 'Mango::Attribute');
    is($attribute->{'product_id'}, 5);
    is($attribute->name, 'CreatedAttribute2');
    is($attribute->value, 'CreatedValue2');
    cmp_ok($attribute->created->epoch, '>=', $current->epoch);

    $attribute = $attributes->next;
    isa_ok($attribute, 'Mango::Attribute');
    is($attribute->{'product_id'}, 5);
    is($attribute->name, 'CreatedAttribute3');
    is($attribute->value, 'CreatedValue3');
    cmp_ok($attribute->created->epoch, '>=', $current->epoch);

    $attribute = $product->add_attribute({
        name => 'CreatedAttribute3', value => 'CreatedValue3'
    });
    isa_ok($attribute, 'Mango::Attribute');
    is($attribute->name, 'CreatedAttribute3');
    is($attribute->value, 'CreatedValue3');
    $attribute->destroy;

    my @tags = $product->add_tags(qw/foo bar baz/);
    is(scalar @tags, 3);

    my $tag = $tags[0];
    isa_ok($tag, 'Mango::Tag');
    is($tag->name, 'foo');

    $tag = $tags[1];
    isa_ok($tag, 'Mango::Tag');
    is($tag->name, 'bar');

    $tag = $tags[2];
    isa_ok($tag, 'Mango::Tag');
    is($tag->name, 'baz');

    $tag = $provider->add_tag($product->id, 'quix');
    isa_ok($tag, 'Mango::Tag');
    is($tag->name, 'quix');

    $tag = $product->add_tag('fark');
    isa_ok($tag, 'Mango::Tag');
    is($tag->name, 'fark');

    my $tags = $product->tags;
    isa_ok($tags, 'Mango::Iterator');
    is($tags->count, 5);

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
        id => 4,
        name => 'updatedproduct4',
        description => 'UpdatedProduct4',
        created  => $date
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
        id => 3,
        name => 'updatedproduct3',
        description => 'UpdatedProduct3',
        created  => $date,
        meta => {
            provider => $provider
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


## update attribute
{
    my $product = $provider->search->first;
    my $attribute = $product->attributes({id => 1})->first;

    $attribute->name('UpdatedName');
    $attribute->value('UpdatedValue');
    $attribute->update;

    $attribute = $product->attributes({id => 1})->first;
    is($attribute->name, 'UpdatedName');
    is($attribute->value, 'UpdatedValue');
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
        id => 2
    });
    ok($provider->delete($product));
    is($provider->search->count, 2);
    is($provider->get_by_id(2), undef);
};


## delete on result object
{
    my $product = Mango::Product->new({
        id => 1,
        meta => {
            provider => $provider
        }
    });
    ok($product->destroy);
    is($provider->search->count, 1);
    is($provider->get_by_id(1), undef);
};


## search throws exception when tag isn't a tag object
{
    try {
        local $ENV{'LANG'} = 'en';
        $provider->search({
            tags => [bless({}, 'Junk')]
        });

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/not a Mango::Tag/i, 'not a Mango::Tag');
    } otherwise {
        fail('Other exception thrown');
    };
};


## add_attribute throws exception when product isn't a product object
{
    try {
        local $ENV{'LANG'} = 'en';
        $provider->add_attributes(bless({}, 'Junk'));

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/not a Mango::Product/i, 'not a Mango::Product');
    } otherwise {
        fail('Other exception thrown');
    };
};

## add_attribute throws exception when attribute isn't a attribute object
{
    my $product = $provider->search->first;

    try {
        local $ENV{'LANG'} = 'en';
        $provider->add_attributes($product, bless({}, 'Junk'));

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/not a Mango::Attribute/i, 'not a Mango::Attribute');
    } otherwise {
        fail('Other exception thrown');
    };
};


## search_attribute throws exception when product isn't a product object
{
    my $product = $provider->search->first;

    try {
        local $ENV{'LANG'} = 'en';
        $provider->search_attributes(bless({}, 'Junk'));

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/not a Mango::Product/i, 'not a Mango::Product');
    } otherwise {
        fail('Other exception thrown');
    };
};


## delete_attribute throws exception when product isn't a product object
{
    my $product = $provider->search->first;

    try {
        local $ENV{'LANG'} = 'en';
        $provider->delete_attributes(bless({}, 'Junk'));

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/not a Mango::Product/i, 'not a Mango::Product');
    } otherwise {
        fail('Other exception thrown');
    };
};


## add_tag throws exception when product isn't a product object
{
    my $product = $provider->search->first;

    try {
        local $ENV{'LANG'} = 'en';
        $provider->add_tags(bless({}, 'Junk'));

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/not a Mango::Product/i, 'not a Mango::Product');
    } otherwise {
        fail('Other exception thrown');
    };
};


## add_tag throws exception when tag isn't a tag object
{
    my $product = $provider->search->first;

    try {
        local $ENV{'LANG'} = 'en';
        $provider->add_tags($product, bless({}, 'Junk'));

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/not a Mango::Tag/i, 'not a Mango::Tag');
    } otherwise {
        fail('Other exception thrown');
    };
};


## add_tag adds nothing if name is undef
{
    my $product = $provider->search->first;

    is($product->tags->count, 5);
    $product->add_tag('');
    is($product->tags->count, 5);
};


## search_tags throws exception when product isn't a product object
{
    my $product = $provider->search->first;

    try {
        local $ENV{'LANG'} = 'en';
        $provider->search_tags(bless({}, 'Junk'));

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/not a Mango::Product/i, 'not a Mango::Product');
    } otherwise {
        fail('Other exception thrown');
    };
};


## delete_tags throws exception when product isn't a product object
{
    my $product = $provider->search->first;

    try {
        local $ENV{'LANG'} = 'en';
        $provider->delete_tags(bless({}, 'Junk'));

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/not a Mango::Product/i, 'not a Mango::Product');
    } otherwise {
        fail('Other exception thrown');
    };
};


## tag destroy throw exception
{
    try {
        local $ENV{'LANG'} = 'en';
        $provider->search->first->tags->first->destroy;

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/not implemented/i, 'method not implemented');
    } otherwise {
        fail('Other exception thrown');
    };
};
