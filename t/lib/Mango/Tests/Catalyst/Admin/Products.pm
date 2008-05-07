# $Id$
package Mango::Tests::Catalyst::Admin::Products;
use strict;
use warnings;

BEGIN {
    use base 'Mango::Test::Class';

    use Test::More;
    use Path::Class ();
}

sub path {'admin/products'};

sub tests_unauthorized: Test(1) {
    my $self = shift;
    my $m = $self->client;

    $m->get('http://localhost/' . $self->path . '/');
    is( $m->status, 401 );
}

sub tests : Test(4) {
    my $self = shift;
    my $m = $self->client;


    ## no tag products
    $m->get_ok('http://localhost/');
    $m->follow_link_ok({text => 'Products'});
    $m->title_like(qr/products/i);
    ok( !$m->find_link( text => 'tag1' ));


    ## login
    $m->follow_link_ok({text => 'Login'});
    $m->title_like(qr/login/i);
    $m->submit_form_ok({
        form_name => 'login',
        fields    => {
            username => 'admin',
            password => 'admin'
        }
    });


    ## get to the admin products page
    $m->follow_link_ok({text => 'Admin'});

    my $path = $self->path;
    $m->follow_link_ok({text => 'Products', url_regex => qr/$path/i});

    my $create = "$path\/create";
    $m->follow_link_ok({url_regex => qr/$create/i});


    ## check field errors
    $m->submit_form_ok({
        form_name => 'admin_products_create',
        fields    => {

        }
    });
    $m->content_like(qr/sku.*required/i);
    $m->content_like(qr/name.*required/i);
    $m->content_like(qr/description.*required/i);
    $m->content_like(qr/price.*required/i);

    

    #$m->content_like(qr/cart is empty/i);
    #is($m->uri->path, '/' . $self->path . '/');

    #is($m->uri->path, '/' . $self->path . '/');


    ## add missing part/sku
    #$m->follow_link_ok({text => 'Products'});
    #$m->title_like(qr/products/i);
    #$m->follow_link_ok({text => 'tag1'});
    #{
    #    local $SIG{__WARN__} = sub {};
    #    $m->submit_form_ok({
    #        form_name => 'cart_add',
    #        fields    => {
    #            sku => 'NOT-FOUND',
    #            quantity => 2
    #        }
    #    });
    #};
    #$m->title_like(qr/cart/i);
    #$m->content_like(qr/part.*could not be found/i);
}

1;