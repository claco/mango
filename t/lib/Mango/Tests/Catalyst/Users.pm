# $Id$
package Mango::Tests::Catalyst::Users;
use strict;
use warnings;

BEGIN {
    use base 'Mango::Test::Class';

    use Test::More;
    use Path::Class ();
}

sub startup : Test(startup => +2) {
    my $self = shift;
    $self->SUPER::startup(@_);

    use_ok('Mango::Provider::Products');
    use_ok('Mango::Provider::Wishlists');

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
        description => 'ABC Product Description'
    });

    $provider = Mango::Provider::Wishlists->new(
            {
                connection_info => [
                    'dbi:SQLite:'
                      . Path::Class::file( $self->application, 'data', 'mango.db' )
                ]
            }
        );
        my $wishlist = $provider->create({
            user_id => 1,
            name => 'My Wishlist',
            description => 'My Wishlist Description'
        });
        $wishlist->add({
            sku => 'ABC-123',
            quantity => 1
        })
}

sub path {'users'};

sub tests : Test(7) {
    my $self = shift;
    my $m = $self->client;

    ## users not found
    $m->get('http://localhost/users' . $self->path . '/');
    is($m->status, 404);
    $m->content_like(qr/resource.*not found/i);


    ## invalid user not found
    $m->get('http://localhost/' . $self->path . '/claco/');
    is($m->status, 404);
    $m->content_like(qr/user.*not.*found/i);


    ## real user
    $m->get_ok('http://localhost/' . $self->path . '/admin/');
    $m->title_like(qr/admin\'s profile/i);
    $m->content_contains('Admin User');
};

sub tests_create : Test(14) {
    my $m = shift->client;

    ## not logged in
    $m->get_ok('http://localhost/');
    $m->follow_link_ok({text => 'Login'});
    $m->title_like(qr/login/i);
    $m->content_unlike(qr/already logged in/i);
    $m->content_unlike(qr/welcome anonymous/i);
    ok(! $m->find_link(text => 'Logout'));


    ## fail login
    $m->submit_form_ok({
        form_name => 'login',
        fields    => {
            username => 'claco',
            password => 'foo'
        }
    });
    $m->title_like(qr/login/i);
    $m->content_like(qr/username or password.*incorrect/i);
    ok(! $m->find_link(text => 'Logout'));


    ## Sign Up
    $m->follow_link_ok({text => 'Sign Up!'});
    $m->submit_form_ok({
        form_name => 'users_create',
        fields    => {
            username => 'claco',
            password => 'foo',
            confirm_password => 'foo',
            first_name => 'Christopher',
            last_name => 'Laco'
        }
    });
    $m->content_like(qr/welcome christopher/i);
    $m->content_like(qr/profile/i);    
}

sub tests_wishlists : Test(12) {
    my $self = shift;
    my $m = $self->client;

    ## view wishlist(s)
    $m->get_ok('http://localhost/' . $self->path . '/admin/');
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
    $m->get('http://localhost/' . $self->path . '/admin/wishlists/999/');
    is($m->status, 404);
    $m->content_like(qr/wishlist.*not.*found/i);
}

1;