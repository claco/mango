#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Test::More tests => 12;

    use Mango::Test ();
    use Mango::Test::Catalyst ();

    use_ok('Mango::Catalyst::Model::Wishlists');
    use_ok('Mango::Exception', ':try');
};


## make sure it acts like a provider and talks to the db
{
    my $c = Mango::Test::Catalyst->new;
    my $model = $c->model('Wishlists');

    ## use faster test schema
    $model->provider->storage->storage->schema_instance(Mango::Test->init_schema);
    isa_ok($model, 'Mango::Catalyst::Model::Wishlists');
    isa_ok($model->provider, 'Mango::Provider::Wishlists');
    is($model->provider_class, 'Mango::Provider::Wishlists');
    is($model->result_class, 'Mango::Wishlist');

    ## search
    my $wishlists = $model->search;
    isa_ok($wishlists, 'Mango::Iterator');
    is($wishlists->count, 3);

    ## create
    my $wishlist = $model->create({
        user => 25,
        name => 'New Wishlist'
    });
    isa_ok($wishlist, 'Mango::Wishlist');
    is($model->search->count, 4);

    ## update w/get_by_id
    $wishlist->name('UpdatedWishlist');
    $model->update($wishlist);
    is($model->get_by_id($wishlist->id)->name, 'UpdatedWishlist');

    ## delete
    $model->delete($wishlist);
    is($model->search->count, 3);
};
