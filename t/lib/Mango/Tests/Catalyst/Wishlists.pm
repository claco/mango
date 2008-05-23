# $Id$
package Mango::Tests::Catalyst::Wishlists;
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
    $provider->create({
        sku => 'ABC-123',
        price => 1.23,
        name => 'ABC Product',
        description => 'ABC Product Description',
        tags => [qw/tag1/]
    });
    $provider->create({
        sku => 'DEF-345',
        price => 10.00,
        name => 'DEF Product',
        description => 'DEF Product Description',
        tags => [qw/tag2/]
    });
}

sub path {'wishlists'};

sub tests : Test(204) {
    my $self = shift;
    my $m = $self->client;

    ## add sku to cart
    $m->get_ok('http://localhost/');
    ok(! $m->find_link(text => 'Wishlists'));

    $m->follow_link_ok({text => 'Products'});
    $m->title_like(qr/products/i);
    $m->follow_link_ok({text => 'tag1'});
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_id => 'cart_add_1',
            fields    => {
                sku => 'ABC-123',
                quantity => 2
            }
        });
    };
    $m->follow_link_ok({text => 'Products'});
    $m->title_like(qr/products/i);
    $m->follow_link_ok({text => 'tag2'});
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_id => 'cart_add_2',
            fields    => {
                sku => 'DEF-345',
                quantity => 1
            }
        });
    };
    $m->title_like(qr/cart/i);
    $m->content_contains('<td align="left">ABC-123</td>');
    $m->content_contains('<td align="left">ABC Product Description</td>');
    $m->content_contains('<td align="right">$1.23</td>');
    $m->content_contains('<td align="right">$2.46</td>');
    $m->content_contains('<td align="left">DEF-345</td>');
    $m->content_contains('<td align="left">DEF Product Description</td>');
    $m->content_contains('<td align="right">$10.00</td>');
    $m->content_contains('<td align="right">$12.46</td>');


    ## login
    $m->follow_link_ok({text => 'Login'});
    $m->submit_form_ok({
        form_id => 'login',
        fields    => {
            username => 'admin',
            password => 'admin'
        }
    });
    $m->title_like(qr/login/i);
    $m->content_like(qr/login successful/i);


    ## save cart
    $m->follow_link_ok({text => 'Cart'});
    $m->title_like(qr/cart/i);
    $m->submit_form_ok({
        form_id => 'cart_save',
        fields => {
            name => 'My New Wishlist',
        }
    });


    ## list wishlists
    $m->title_like(qr/wishlists/i);
    is($m->uri->path, '/' . $self->path . '/');
    $m->content_contains('My New Wishlist');
    $m->content_contains('No description available');


    ## view wishlist
    $m->follow_link_ok({text => 'My New Wishlist'});
    $m->title_like(qr/My New Wishlist/i);
    $m->content_contains('My New Wishlist');
    $m->content_contains('<td align="left">ABC-123</td>');
    $m->content_contains('<td align="left">ABC Product Description</td>');
    $m->content_contains('<td align="right">$1.23</td>');
    $m->content_contains('<td align="right">$2.46</td>');
    $m->content_contains('<td align="left">DEF-345</td>');
    $m->content_contains('<td align="left">DEF Product Description</td>');
    $m->content_contains('<td align="right">$10.00</td>');
    $m->content_contains('<td align="right">$12.46</td>');


    ## update item
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_id => 'wishlists_items_update_1',
            fields    => {
                quantity => 3
            }
        });
    };
    $m->title_like(qr/My New Wishlist/i);
    $m->content_contains('My New Wishlist');
    $m->content_contains('<td align="left">ABC-123</td>');
    $m->content_contains('<td align="left">ABC Product Description</td>');
    $m->content_contains('<td align="right">$1.23</td>');
    $m->content_contains('<td align="right">$3.69</td>');
    $m->content_contains('<td align="left">DEF-345</td>');
    $m->content_contains('<td align="left">DEF Product Description</td>');
    $m->content_contains('<td align="right">$10.00</td>');
    $m->content_contains('<td align="right">$13.69</td>');


    ## update with non numeric
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_id => 'wishlists_items_update_1',
            fields    => {
                quantity => 'a'
            }
        });
    };
    $m->title_like(qr/My New Wishlist/i);
    $m->content_like(qr/quantity must be.*number/i);
    $m->content_contains('<td align="left">ABC-123</td>');
    $m->content_contains('<td align="left">ABC Product Description</td>');
    $m->content_contains('<td align="right">$1.23</td>');
    $m->content_contains('<td align="right">$3.69</td>');
    $m->content_contains('<td align="left">DEF-345</td>');
    $m->content_contains('<td align="left">DEF Product Description</td>');
    $m->content_contains('<td align="right">$10.00</td>');
    $m->content_contains('<td align="right">$13.69</td>');


    ## delete item
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_id => 'wishlists_items_delete_1',
        });
    };
    $m->title_like(qr/My New Wishlist/i);
    $m->content_contains('My New Wishlist');
    $m->content_lacks('<td align="left">ABC-123</td>');
    $m->content_lacks('<td align="left">ABC Product Description</td>');
    $m->content_lacks('<td align="right">$1.23</td>');
    $m->content_lacks('<td align="right">$3.69</td>');
    $m->content_contains('<td align="left">DEF-345</td>');
    $m->content_contains('<td align="left">DEF Product Description</td>');
    $m->content_contains('<td align="right">$10.00</td>');


    ## edit wishlist
    $m->follow_link_ok({text => 'Edit'});
    $m->content_contains('Editing My New Wishlist');
    $m->submit_form_ok({
        form_id => 'wishlists_edit',
        fields    => {
            name => 'My Updated Wishlist',
            description => 'My Updated Description'
        }
    });
    $m->title_like(qr/My Updated Wishlist/i);
    $m->content_contains('My Updated Wishlist');
    $m->content_contains('My Updated Description');
    $m->content_contains('<td align="left">DEF-345</td>');
    $m->content_contains('<td align="left">DEF Product Description</td>');
    $m->content_contains('<td align="right">$10.00</td>');


    ## clear wishlist
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_id => 'wishlists_clear',
        });
    };
    $m->title_like(qr/My Updated Wishlist/i);
    $m->content_contains('My Updated Wishlist');
    $m->content_like(qr/wishlist is empty/i);
    $m->content_lacks('<td align="left">ABC-123</td>');
    $m->content_lacks('<td align="left">ABC Product Description</td>');
    $m->content_lacks('<td align="right">$1.23</td>');
    $m->content_lacks('<td align="right">$3.69</td>');
    $m->content_lacks('<td align="left">DEF-345</td>');
    $m->content_lacks('<td align="left">DEF Product Description</td>');
    $m->content_lacks('<td align="right">$10.00</td>');


    ## delete wishlist
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_id => 'wishlists_delete',
        });
    };
    $m->title_like(qr/wishlists/i);
    $m->content_lacks('My Updated Wishlist');
    $m->content_lacks('My Updated Description');
    $m->content_like(qr/no wishlists/i);


    ## restore wishlist into cart: append=3
    $m->follow_link_ok({text => 'Cart'});
    $m->title_like(qr/cart/i);
    $m->content_like(qr/cart is empty/i);
    $m->follow_link_ok({text => 'Products'});
    $m->title_like(qr/products/i);
    $m->follow_link_ok({text => 'tag1'});
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_id => 'cart_add_1',
            fields    => {
                sku => 'ABC-123',
                quantity => 1
            }
        });
    };
    $m->title_like(qr/cart/i);
    $m->content_contains('<td align="left">ABC-123</td>');
    $m->content_contains('<td align="left">ABC Product Description</td>');
    $m->content_contains('<td align="right">$1.23</td>');
    $m->submit_form_ok({
        form_id => 'cart_save',
        fields => {
            name => 'My New Wishlist',
        }
    });
    $m->follow_link_ok({text => 'My New Wishlist'});
    $m->title_like(qr/My New Wishlist/i);
    $m->content_contains('<td align="left">ABC-123</td>');
    $m->content_contains('<td align="left">ABC Product Description</td>');
    $m->content_contains('<td align="right">$1.23</td>');
    $m->follow_link_ok({text => 'Products'});
    $m->title_like(qr/products/i);
    $m->follow_link_ok({text => 'tag2'});
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_id => 'cart_add_2',
            fields    => {
                sku => 'DEF-345',
                quantity => 1
            }
        });
    };
    $m->title_like(qr/cart/i);
    $m->content_lacks('<td align="left">ABC-123</td>');
    $m->content_lacks('<td align="left">ABC Product Description</td>');
    $m->content_lacks('<td align="right">$1.23</td>');
    $m->content_contains('<td align="left">DEF-345</td>');
    $m->content_contains('<td align="left">DEF Product Description</td>');
    $m->content_contains('<td align="right">$10.00</td>');
    $m->follow_link_ok({text => 'Wishlists'});
    $m->follow_link_ok({text => 'My New Wishlist'});
    $m->title_like(qr/My New Wishlist/i);
    $m->submit_form_ok({
        form_id => 'wishlists_restore',
        fields    => {
            mode => 3
        }
    });
    $m->title_like(qr/cart/i);
    $m->content_contains('<td align="left">ABC-123</td>');
    $m->content_contains('<td align="left">ABC Product Description</td>');
    $m->content_contains('<td align="right">$1.23</td>');
    $m->content_contains('<td align="left">DEF-345</td>');
    $m->content_contains('<td align="left">DEF Product Description</td>');
    $m->content_contains('<td align="right">$10.00</td>');
    $m->content_contains('<td align="right">$11.23</td>');
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_id => 'cart_clear'
        });
    };
    $m->title_like(qr/cart/i);
    $m->content_lacks('<td align="left">ABC-123</td>');
    $m->content_lacks('<td align="left">ABC Product Description</td>');
    $m->content_lacks('<td align="right">$1.23</td>');
    $m->content_lacks('<td align="left">DEF-345</td>');
    $m->content_lacks('<td align="left">DEF Product Description</td>');
    $m->content_lacks('<td align="right">$10.00</td>');
    $m->content_lacks('<td align="right">$11.23</td>');
    $m->content_like(qr/cart is empty/i);


    ## restore wishlist into cart: merge=2
    $m->follow_link_ok({text => 'Cart'});
    $m->title_like(qr/cart/i);
    $m->content_like(qr/cart is empty/i);
    $m->follow_link_ok({text => 'Products'});
    $m->title_like(qr/products/i);
    $m->follow_link_ok({text => 'tag1'});
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_id => 'cart_add_1',
            fields    => {
                sku => 'ABC-123',
                quantity => 1
            }
        });
    };
    $m->title_like(qr/cart/i);
    $m->content_contains('<td align="left">ABC-123</td>');
    $m->content_contains('<td align="left">ABC Product Description</td>');
    $m->content_contains('<td align="right">$1.23</td>');
    $m->follow_link_ok({text => 'Wishlists'});
    $m->follow_link_ok({text => 'My New Wishlist'});
    $m->title_like(qr/My New Wishlist/i);
    $m->submit_form_ok({
        form_id => 'wishlists_restore',
        fields    => {
            mode => 2
        }
    });
    $m->title_like(qr/cart/i);
    $m->content_contains('<td align="left">ABC-123</td>');
    $m->content_contains('<td align="left">ABC Product Description</td>');
    $m->content_contains('<td align="right">$1.23</td>');
    $m->content_contains('<td align="right">$2.46</td>');
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_id => 'cart_clear'
        });
    };
    $m->title_like(qr/cart/i);
    $m->content_lacks('<td align="left">ABC-123</td>');
    $m->content_lacks('<td align="left">ABC Product Description</td>');
    $m->content_lacks('<td align="right">$1.23</td>');
    $m->content_lacks('<td align="right">$2.46</td>');
    $m->content_like(qr/cart is empty/i);


    ## restore wishlist into cart: replace=1
    $m->follow_link_ok({text => 'Cart'});
    $m->title_like(qr/cart/i);
    $m->content_like(qr/cart is empty/i);
    $m->follow_link_ok({text => 'Products'});
    $m->title_like(qr/products/i);
    $m->follow_link_ok({text => 'tag2'});
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_id => 'cart_add_2',
            fields    => {
                sku => 'DEF-345',
                quantity => 1
            }
        });
    };
    $m->title_like(qr/cart/i);
    $m->content_contains('<td align="left">DEF-345</td>');
    $m->content_contains('<td align="left">DEF Product Description</td>');
    $m->content_contains('<td align="right">$10.00</td>');
    $m->follow_link_ok({text => 'Wishlists'});
    $m->follow_link_ok({text => 'My New Wishlist'});
    $m->title_like(qr/My New Wishlist/i);
    $m->submit_form_ok({
        form_id => 'wishlists_restore',
        fields    => {
            mode => 1
        }
    });
    $m->title_like(qr/cart/i);
    $m->content_contains('<td align="left">ABC-123</td>');
    $m->content_contains('<td align="left">ABC Product Description</td>');
    $m->content_contains('<td align="right">$1.23</td>');
    $m->content_lacks('<td align="left">DEF-345</td>');
    $m->content_lacks('<td align="left">DEF Product Description</td>');
    $m->content_lacks('<td align="right">$10.00</td>');
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_id => 'cart_clear'
        });
    };
    $m->title_like(qr/cart/i);
    $m->content_lacks('<td align="left">ABC-123</td>');
    $m->content_lacks('<td align="left">ABC Product Description</td>');
    $m->content_lacks('<td align="right">$1.23</td>');
    $m->content_lacks('<td align="right">$2.46</td>');
    $m->content_like(qr/cart is empty/i);
};

sub tests_not_found : Test(1) {
    my $self = shift;
    my $m = $self->client;

    $m->get('http://localhost/wishlists/');

    if ($self->path eq 'wishlists') {
        is( $m->status, 401 );
    } else {
        is( $m->status, 404 );
    }
}

sub tests_unauthorized: Test(1) {
    my $self = shift;
    my $m = $self->client;

    $m->get('http://localhost/' . $self->path . '/');
    is( $m->status, 401 );
}

1;