#!perl -wT
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 12;
    use Mango::Test::Catalyst;

    use_ok('Mango::Catalyst::Model::Products');
    use_ok('Mango::Exception', ':try');
};


## make sure it acts like a provider and talks to the db
{
    my $c = Mango::Test::Catalyst->new;
    my $model = $c->model('Products');

    ## use faster test schema
    $model->schema(Mango::Test->init_schema);
    isa_ok($model, 'Mango::Catalyst::Model::Products');
    isa_ok($model->provider, 'Mango::Provider::Products');
    is($model->provider_class, 'Mango::Provider::Products');
    is($model->result_class, 'Mango::Product');

    ## search
    my $products = $model->search;
    isa_ok($products, 'Mango::Iterator');
    is($products->count, 3);

    ## create
    my $product = $model->create({
        sku => 'NEWSKU',
        name => 'New Product',
        price => 0.00
    });
    isa_ok($product, 'Mango::Product');
    is($model->search->count, 4);

    ## update w/get_by_id
    $product->sku('UPDATEDSKU');
    $model->update($product);
    is($model->get_by_id($product->id)->sku, 'UPDATEDSKU');

    ## delete
    $model->delete($product);
    is($model->search->count, 3);
};
