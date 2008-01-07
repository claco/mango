#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 96;
    use Path::Class 'file';

    use_ok('Mango::Provider::Products');

    my $provider = Mango::Provider::Products->new({
        connection_info => ['dbi:SQLite:' . file(
            Mango::Test->mk_app, 'data', 'mango.db'
        )]
    });
    $provider->create({
        sku => 'ABC-123',
        price => 1.23,
        name => 'ABC Product',
        description => 'ABC Product Description'
    });
    $provider->create({
        sku => 'DEF-345',
        price => 10.00,
        name => 'DEF Product',
        description => 'DEF Product Description'
    });
};


{
    my $m = Test::WWW::Mechanize::Catalyst->new;

    ## add sku to cart
    $m->get_ok('http://localhost/');
    ok(! $m->find_link(text => 'Wishlists'));

    $m->follow_link_ok({text => 'Products'});
    $m->title_like(qr/products/i);
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
    $m->follow_link_ok({text => 'Products'});
    $m->title_like(qr/products/i);
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_name => 'cart_add',
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
        form_name => 'login',
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

    my $r = $m->submit_form_ok({
        form_name => 'cart_save',
        fields => {
            name => 'My New Wishlist',
        }
    });

    ## list wishlists
    $m->title_like(qr/wishlists/i);
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
            form_name => 'wishlists_items_update',
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
            form_name => 'wishlists_items_update',
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
            form_name => 'wishlists_items_delete',
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
        form_name => 'wishlists_edit',
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
            form_name => 'wishlists_clear',
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
            form_name => 'wishlists_delete',
        });
    };
    $m->title_like(qr/wishlists/i);
    $m->content_lacks('My Updated Wishlist');
    $m->content_lacks('My Updated Description');
    $m->content_like(qr/no wishlists/i);
};