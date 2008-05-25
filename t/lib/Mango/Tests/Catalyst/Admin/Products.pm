# $Id$
package Mango::Tests::Catalyst::Admin::Products;
use strict;
use warnings;

BEGIN {
    use base 'Mango::Test::Class';

    use Test::More;
    use Path::Class ();
}

sub startup : Test(startup => +1) {
    my $self = shift;
    $self->SUPER::startup(@_);

    use_ok('Mango::Provider::Products');

    my $provider = Mango::Provider::Products->new(
        {
            connection_info => [
                'dbi:SQLite:'
                  . Path::Class::file( $self->application, 'data', 'mango.db' )
            ]
        }
    );
    $provider->create(
        {
            sku         => 'DEF-345',
            price       => 10.00,
            name        => 'DEF Product',
            description => 'DEF Product Description',
            tags        => [qw/tag2/],
            attributes  => [
                {
                    name => 'ExistingAttribute',
                    value => 'ExistingValue'
                }
            ]
        }
    );
}

sub path {'admin/products'};

sub tests_unauthorized: Test(1) {
    my $self = shift;
    my $m = $self->client;

    $m->get('http://localhost/' . $self->path . '/');
    is( $m->status, 401 );
}

sub tests : Test(113) {
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
        form_id => 'login',
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
        form_id => 'admin_products_create',
        fields    => {}
    });
    $m->content_contains('<li>CONSTRAINT_SKU_NOT_BLANK</li>');
    $m->content_contains('<li>The name field is required.</li>');
    $m->content_contains('<li>CONSTRAINT_DESCRIPTION_NOT_BLANK</li>');
    $m->content_contains('<li>CONSTRAINT_PRICE_NOT_BLANK</li>');


    ## fail to add existing product
    $m->submit_form_ok({
        form_id => 'admin_products_create',
        fields    => {
            sku   => 'DEF-345',
            name  => 'My SKU',
            description => 'My SKU Description',
            price => 1.23,
            tags  => 'tag1'
        }
    });
    $m->content_contains('<li>CONSTRAINT_SKU_UNIQUE</li>');


    ## add new product
    $m->submit_form_ok({
        form_id => 'admin_products_create',
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
    is($m->uri->path, '/' . $self->path . '/2/edit/');


    ## add attributes
    $m->follow_link_ok({text_regex => qr/edit.*attributes/i, url_regex => qr/attributes/i});
    $m->follow_link_ok({text_regex => qr/new.*attribute/i, url_regex => qr/create/i});
    $m->submit_form_ok({
        form_id => 'admin_products_attributes_create',
        fields    => {
            name => '',
            value => ''
        }
    });
    $m->content_contains('<li>The name field is required.</li>');
    $m->content_contains('<li>CONSTRAINT_VALUE_NOT_BLANK</li>');
    $m->submit_form_ok({
        form_id => 'admin_products_attributes_create',
        fields    => {
            name  => 'Attribute1',
            value => 'Value1'
        }
    });
    $m->content_lacks('<li>The name field is required.</li>');
    $m->content_lacks('<li>CONSTRAINT_VALUE_NOT_BLANK</li>');
    is($m->uri->path, '/' . $self->path . '/2/attributes/2/edit/');


    ## edit exiting product
    $m->follow_link_ok({text => 'Products', url_regex => qr/$path/i});
    $m->follow_link_ok({text_regex => qr/DEF-345/, url_regex => qr/edit/i});
    is($m->uri->path, '/' . $self->path . '/1/edit/');


    ## fail edit
    $m->submit_form_ok({
        form_id => 'admin_products_edit',
        fields    => {
            sku   => '',
            name  => '',
            description => '',
            price => ''
        }
    });
    $m->content_contains('<li>CONSTRAINT_SKU_NOT_BLANK</li>');
    $m->content_contains('<li>The name field is required.</li>');
    $m->content_contains('<li>CONSTRAINT_DESCRIPTION_NOT_BLANK</li>');
    $m->content_contains('<li>CONSTRAINT_PRICE_NOT_BLANK</li>');


    ## fail edit duplicate product
    $m->submit_form_ok({
        form_id => 'admin_products_edit',
        fields    => {
            sku => 'ABC-123',
            name  => 'My DEF SKU',
            description => 'My DEF Description',
            price => 3.45,
            tags  => 'tag3'
        }
    });
    $m->content_contains('<li>CONSTRAINT_SKU_UNIQUE</li>');


    ## continue edit
    $m->submit_form_ok({
        form_id => 'admin_products_edit',
        fields    => {
            sku => 'DEF-345',
            name  => 'My DEF SKU',
            description => 'My DEF Description',
            price => 3.45,
            tags  => 'tag3'
        }
    });
    $m->content_lacks('<li>CONSTRAINT_SKU_NOT_BLANK</li>');
    $m->content_lacks('<li>The name field is required.</li>');
    $m->content_lacks('<li>CONSTRAINT_DESCRIPTION_NOT_BLANK</li>');
    $m->content_lacks('<li>CONSTRAINT_PRICE_NOT_BLANK</li>');


    ## fail adding duplicate attribute
    $m->follow_link_ok({text_regex => qr/edit.*attributes/i, url_regex => qr/attributes/i});
     $m->follow_link_ok({text_regex => qr/new.*attribute/i, url_regex => qr/create/i});
     $m->submit_form_ok({
         form_id => 'admin_products_attributes_create',
         fields    => {
             name => 'ExistingAttribute',
             value => 'Existingvalue'
         }
     });
     $m->content_contains('<li>CONSTRAINT_NAME_UNIQUE</li>');


    ## edit existing attribute
    $m->follow_link_ok({text => 'Products', url_regex => qr/$path/i});
    $m->follow_link_ok({text_regex => qr/DEF-345/, url_regex => qr/edit/i});
    $m->follow_link_ok({text_regex => qr/edit.*attributes/i, url_regex => qr/attributes/i});
    $m->follow_link_ok({text_regex => qr/ExistingAttribute/i, url_regex => qr/attributes.*edit/i});
    $m->submit_form_ok({
        form_id => 'admin_products_attributes_edit',
        fields    => {
            name => '',
            value => ''
        }
    });
    $m->content_contains('<li>The name field is required.</li>');
    $m->content_contains('<li>CONSTRAINT_VALUE_NOT_BLANK</li>');
    $m->submit_form_ok({
        form_id => 'admin_products_attributes_edit',
        fields    => {
            name => 'EditAttribute',
            value => 'EditValue'
        }
    });
    $m->content_lacks('<li>The name field is required.</li>');
    $m->content_lacks('<li>CONSTRAINT_VALUE_NOT_BLANK</li>');


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
    $m->content_contains('Attribute1: Value1');


    ## view edited product in list
    $m->get_ok('http://localhost/');
    $m->follow_link_ok({text => 'Products'});
    $m->title_like(qr/products/i);
    $m->follow_link_ok({text => 'tag3'});
    is($m->uri->path, '/products/tags/tag3/');
    $m->content_contains('DEF-345');
    $m->content_contains('My DEF Description');
    $m->content_contains('$3.45');


    ## view edited product
    $m->follow_link_ok({text => 'My DEF SKU'});
    is($m->uri->path, '/products/DEF-345/');
    $m->content_contains('DEF-345');
    $m->content_contains('My DEF Description');
    $m->content_contains('$3.45');
    $m->content_contains('EditAttribute: EditValue');
    $m->content_lacks('ExistingAttribute: ExistingValue');


    ## delete an attribute
    $m->follow_link_ok({text => 'Admin'});
    $m->follow_link_ok({text => 'Products', url_regex => qr/$path/i});
    $m->follow_link_ok({text_regex => qr/DEF-345/, url_regex => qr/edit/i});
    is($m->uri->path, '/' . $self->path . '/1/edit/');
    $m->follow_link_ok({text_regex => qr/edit.*attributes/i, url_regex => qr/attributes/i});
    $m->submit_form_ok({
        form_id => 'admin_products_attributes_delete_1',
    });


    ## delete a product
    $m->follow_link_ok({text => 'Admin'});
    $m->follow_link_ok({text => 'Products', url_regex => qr/$path/i});
    $m->submit_form_ok({
        form_id => 'admin_products_delete_2'
    });


    ## verify deletes
    $m->get_ok('http://localhost/');
    $m->follow_link_ok({text => 'Products'});
    $m->title_like(qr/products/i);
    ok(!$m->find_link(text => 'tag1'));
    $m->get('http://localhost/' . $self->path . '/ABC-123/');
    is($m->status, 404);

    $m->get_ok('http://localhost/');
    $m->follow_link_ok({text => 'Products'});
    $m->follow_link_ok({text => 'tag3'});
    $m->follow_link_ok({text => 'My DEF SKU'});
    is($m->uri->path, '/products/DEF-345/');
    $m->content_contains('DEF-345');
    $m->content_contains('My DEF Description');
    $m->content_contains('$3.45');
    $m->content_lacks('EditAttribute: EditValue');
}

1;