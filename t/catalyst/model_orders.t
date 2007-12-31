#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 12;
    use Mango::Test::Catalyst;

    use_ok('Mango::Catalyst::Model::Orders');
    use_ok('Mango::Exception', ':try');
};


## make sure it acts like a provider and talks to the db
{
    my $c = Mango::Test::Catalyst->new;
    my $model = $c->model('Orders');

    ## use faster test schema
    $model->provider->storage->storage->schema_instance(Mango::Test->init_schema);
    isa_ok($model, 'Mango::Catalyst::Model::Orders');
    isa_ok($model->provider, 'Mango::Provider::Orders');
    is($model->provider_class, 'Mango::Provider::Orders');
    is($model->result_class, 'Mango::Order');

    ## search
    my $orders = $model->search;
    isa_ok($orders, 'Mango::Iterator');
    is($orders->count, 3);

    ## create
    my $order = $model->create({
        user => 25,
    });
    isa_ok($order, 'Mango::Order');
    is($model->search->count, 4);

    ## update w/get_by_id
    $order->number(12345);
    $model->update($order);
    is($model->get_by_id($order->id)->number, 12345);

    ## delete
    $model->delete($order);
    is($model->search->count, 3);
};
