# $Id$
package Mango::Tests::Catalyst::Cart;
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
            sku         => 'ABC-123',
            price       => 1.23,
            name        => 'ABC Product',
            description => 'ABC Product Description',
            tags        => [qw/tag1/]
        }
    );
    $provider->create(
        {
            sku         => 'DEF-345',
            price       => 10.00,
            name        => 'DEF Product',
            description => 'DEF Product Description',
            tags        => [qw/tag2/]
        }
    );
}

sub path {'cart'};

sub tests : Test(80) {
    my $self = shift;
    my $m = $self->client;

    ## cart is empty
    $m->get_ok('http://localhost/');
    $m->follow_link_ok({text => 'Cart'});
    $m->title_like(qr/cart/i);
    $m->content_like(qr/cart is empty/i);
    is($m->uri->path, '/' . $self->path . '/');

    ## add missing part/sku
    $m->follow_link_ok({text => 'Products'});
    $m->title_like(qr/products/i);
    $m->follow_link_ok({text => 'tag1'});
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_name => 'cart_add',
            fields    => {
                sku => 'NOT-FOUND',
                quantity => 2
            }
        });
    };
    $m->title_like(qr/cart/i);
    $m->content_like(qr/part.*could not be found/i);


    ## add existing part/sku
    $m->follow_link_ok({text => 'Products'});
    $m->title_like(qr/products/i);
    $m->follow_link_ok({text => 'tag1'});
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_name => 'cart_add',
            fields    => {
                sku => 'ABC-123',
                quantity => 2
            }
        });
    };
    $m->title_like(qr/cart/i);
    $m->content_contains('<td align="left">ABC-123</td>');
    $m->content_contains('<td align="left">ABC Product Description</td>');
    $m->content_contains('<td align="right">$1.23</td>');
    $m->content_contains('<td align="right">$2.46</td>');


    ## update quantity
    $m->submit_form_ok({
        form_name => 'cart_items_update',
        fields    => {
            quantity => 3
        }
    });
    $m->title_like(qr/cart/i);
    $m->content_contains('<td align="left">ABC-123</td>');
    $m->content_contains('<td align="left">ABC Product Description</td>');
    $m->content_contains('<td align="right">$1.23</td>');
    $m->content_contains('<td align="right">$3.69</td>');


    ## update with non numeric
    $m->submit_form_ok({
        form_name => 'cart_items_update',
        fields    => {
            quantity => 'a'
        }
    });
    $m->title_like(qr/cart/i);
    $m->content_like(qr/quantity must be.*number/i);
    $m->content_contains('<td align="left">ABC-123</td>');
    $m->content_contains('<td align="left">ABC Product Description</td>');
    $m->content_contains('<td align="right">$1.23</td>');
    $m->content_contains('<td align="right">$3.69</td>');


    ## add another item
    $m->follow_link_ok({text => 'Products'});
    $m->title_like(qr/products/i);
    $m->follow_link_ok({text => 'tag2'});
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_name => 'cart_add',
            fields    => {
                sku => 'DEF-345',
                quantity => 2
            }
        });
    };
    $m->title_like(qr/cart/i);
    $m->content_contains('<td align="left">ABC-123</td>');
    $m->content_contains('<td align="left">ABC Product Description</td>');
    $m->content_contains('<td align="right">$1.23</td>');
    $m->content_contains('<td align="right">$3.69</td>');
    $m->content_contains('<td align="left">DEF-345</td>');
    $m->content_contains('<td align="left">DEF Product Description</td>');
    $m->content_contains('<td align="right">$10.00</td>');
    $m->content_contains('<td align="right">$20.00</td>');
    $m->content_contains('<td align="right">$23.69</td>');


    ## delete an item
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_name => 'cart_items_delete'
        });
    };
    $m->title_like(qr/cart/i);
    $m->content_lacks('<td align="left">ABC-123</td>');
    $m->content_lacks('<td align="left">ABC Product Description</td>');
    $m->content_lacks('<td align="right">$1.23</td>');
    $m->content_lacks('<td align="right">$3.69</td>');
    $m->content_contains('<td align="left">DEF-345</td>');
    $m->content_contains('<td align="left">DEF Product Description</td>');
    $m->content_contains('<td align="right">$10.00</td>');
    $m->content_contains('<td align="right">$20.00</td>');


    ## can't save as anonymous
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_name => 'cart_save'
        });
    };
    $m->title_like(qr/cart/i);
    $m->content_like(qr/must be logged in/i);


    ## can't save if name is missing
    $m->follow_link_ok({text => 'Login'});
    $m->submit_form_ok({
        form_name => 'login',
        fields    => {
            username => 'admin',
            password => 'admin'
        }
    });
    $m->title_like(qr/login/i);
    $m->content_like(qr/login successful/i);
    $m->follow_link_ok({text => 'Cart'});
    $m->title_like(qr/cart/i);
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_name => 'cart_save',
        });
    };
    $m->title_like(qr/cart/i);
    $m->content_like(qr/name field is required/i);
    

    ## clear the cart
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_name => 'cart_clear'
        });
    };
    $m->title_like(qr/cart/i);
    $m->content_lacks('<td align="left">ABC-123</td>');
    $m->content_lacks('<td align="left">ABC Product Description</td>');
    $m->content_lacks('<td align="right">$1.23</td>');
    $m->content_lacks('<td align="right">$3.69</td>');
    $m->content_lacks('<td align="left">DEF-345</td>');
    $m->content_lacks('<td align="left">DEF Product Description</td>');
    $m->content_lacks('<td align="right">$10.00</td>');
    $m->content_lacks('<td align="right">$20.00</td>');
    $m->content_like(qr/cart is empty/i);
}

1;