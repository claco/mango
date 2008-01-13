#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 14;
    use Path::Class 'file';

    use_ok('Mango::Provider::Products');
    use_ok('Mango::Provider::Wishlists');

    my $temp = Mango::Test->mk_app;
    my $provider = Mango::Provider::Products->new({
        connection_info => ['dbi:SQLite:' . file(
            $temp, 'data', 'mango.db'
        )]
    });
    $provider->create({
        sku => 'ABC-123',
        price => 1.23,
        name => 'ABC Product',
        description => 'ABC Product Description'
    });

    $provider = Mango::Provider::Wishlists->new({
        connection_info => ['dbi:SQLite:' . file(
            $temp, 'data', 'mango.db'
        )]
    });
    my $wishlist = $provider->create({
        user_id => 1,
        name => 'My Wishlist',
        description => 'My Wishlist Description'
    });
    $wishlist->add({
        sku => 'ABC-123',
        quantity => 1
    })
};


{
    my $m = Test::WWW::Mechanize::Catalyst->new;


    ## view wishlist(s)
    $m->get_ok('http://localhost/users/admin/');
    $m->title_like(qr/admin\'s profile/i);
    $m->follow_link_ok({text => 'Admin\'s Wishlists'});
    $m->title_like(qr/admin\'s wishlists/i);
    $m->content_contains('My Wishlist');
    $m->content_contains('My Wishlist Description');
    $m->follow_link_ok({text => 'My Wishlist'});
    $m->title_like(qr/my wishlist/i);
    $m->content_contains('ABC-123');
    $m->content_contains('<td align="right">$1.23</td>');


    ## invalid wishlist not found
    $m->get('http://localhost/users/admin/wishlists/999/');
    is($m->status, 404);
    $m->content_like(qr/wishlist.*not.*found/i);
};