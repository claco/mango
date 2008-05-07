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

sub tests : Test(35) {
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


    ## fail to add product
    $m->submit_form_ok({
        form_name => 'admin_products_create',
        fields    => {}
    });
    $m->content_contains('<li>CONSTRAINT_SKU_NOT_BLANK</li>');
    $m->content_contains('<li>The name field is required.</li>');
    $m->content_contains('<li>CONSTRAINT_DESCRIPTION_NOT_BLANK</li>');
    $m->content_contains('<li>CONSTRAINT_PRICE_NOT_BLANK</li>');


    ## add new product
    $m->submit_form_ok({
        form_name => 'admin_products_create',
        fields    => {
            sku   => 'ABC-123',
            name  => 'My SKU',
            description => 'My SKU Description',
            price => 1.23,
            tags  => 'tag1'
        }
    });
    $m->content_lacks('<li>CONSTRAINT_SKU_NOT_BLANK</li>');
    $m->content_lacks('<li>The name field is required.</li>');
    $m->content_lacks('<li>CONSTRAINT_DESCRIPTION_NOT_BLANK</li>');
    $m->content_lacks('<li>CONSTRAINT_PRICE_NOT_BLANK</li>');
    is($m->uri->path, '/' . $self->path . '/1/edit/');


    ## view new product in list
    $m->get_ok('http://localhost/');
    $m->follow_link_ok({text => 'Products'});
    $m->title_like(qr/products/i);
    $m->follow_link_ok({text => 'tag1'});
    is($m->uri->path, '/products/tags/tag1/');
    $m->content_contains('ABC-123');
    $m->content_contains('My SKU Description');
    $m->content_contains('$1.23');


    ## view new product
    $m->follow_link_ok({text => 'My SKU'});
    is($m->uri->path, '/products/ABC-123/');
    $m->content_contains('ABC-123');
    $m->content_contains('My SKU Description');
    $m->content_contains('$1.23');
}

1;