#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 24;
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
    $m->title_like(qr/cart/i);
    $m->content_contains('<td align="left">ABC-123</td>');
    $m->content_contains('<td align="left">ABC Product Description</td>');
    $m->content_contains('<td align="right">$1.23</td>');
    $m->content_contains('<td align="right">$2.46</td>');


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
            name => 'My New Wishlist'
        }
    });
    $m->title_like(qr/wishlists/i);


    ## list wishlists
    $m->content_contains('My New Wishlist');


    ## view wishlist
    $m->follow_link_ok({text => 'My New Wishlist'});
    $m->content_contains('My New Wishlist');


    ## edit wishlist
    $m->follow_link_ok({text => 'Edit'});
    $m->content_contains('My New Wishlist');
};