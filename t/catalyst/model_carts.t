#!perl -wT
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 12;
    use Mango::Test::Catalyst;

    use_ok('Mango::Catalyst::Model::Carts');
    use_ok('Mango::Exception', ':try');
};


## make sure it acts like a provider and talks to the db
{
    my $c = Mango::Test::Catalyst->new;
    my $model = $c->model('Carts');

    ## use faster test schema
    $model->provider->storage->storage->schema_instance(Mango::Test->init_schema);
    isa_ok($model, 'Mango::Catalyst::Model::Carts');
    isa_ok($model->provider, 'Mango::Provider::Carts');
    is($model->provider_class, 'Mango::Provider::Carts');
    is($model->result_class, 'Mango::Cart');

    ## search
    my $carts = $model->search;
    isa_ok($carts, 'Mango::Iterator');
    is($carts->count, 2);

    ## create
    my $cart = $model->create({
        user => 25
    });
    isa_ok($cart, 'Mango::Cart');
    is($model->search->count, 3);

    ## update w/get_by_id
    $cart->user_id(26);
    $model->update($cart);
    is($model->get_by_id($cart->id)->user_id, 26);

    ## delete
    $model->delete($cart);
    is($model->search->count, 2);
};
