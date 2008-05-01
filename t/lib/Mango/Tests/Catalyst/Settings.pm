# $Id$
package Mango::Tests::Catalyst::Settings;
use strict;
use warnings;

BEGIN {
    use base 'Mango::Test::Class';

    use Test::More;
    use Path::Class ();
}

sub path {'settings'};

sub tests : Test(31) {
    my $self = shift;
    my $m = $self->client;

    ## not logged in
    $m->get_ok('http://localhost/');
    $m->follow_link_ok({text => 'Login'});
    $m->title_like(qr/login/i);
    $m->content_unlike(qr/already logged in/i);
    $m->content_unlike(qr/welcome anonymous/i);
    ok(! $m->find_link(text => 'Logout'));
    ok(! $m->find_link(text => 'Profile'));

    ## login
    $m->submit_form_ok({
        form_name => 'login',
        fields    => {
            username => 'admin',
            password => 'admin'
        }
    });
    $m->title_like(qr/login/i);
    $m->content_like(qr/login successful/i);
    $m->content_like(qr/welcome admin/i);
    ok(! $m->find_link(text => 'Login'));
    ok($m->find_link(text => 'Logout'));


    ## edit profile
    $m->follow_link_ok({text => 'Profile'});
    is($m->uri->path, '/' . $self->path . '/profile/');
    $m->title_like(qr/profile/i);
    $m->submit_form_ok({
        form_name => 'settings_profile',
        fields    => {
            password => 'admin',
            confirm_password => 'admin',
            first_name => 'Administration',
            last_name => 'User'
        }
    });
    $m->title_like(qr/profile/i);
    $m->content_like(qr/welcome administration/i);


    ## logout
    $m->follow_link_ok({text => 'Logout'});
    $m->content_like(qr/logout successful/i);
    $m->content_unlike(qr/welcome administration/i);
    ok($m->find_link(text => 'Login'));
    ok(! $m->find_link(text => 'Logout'));

    ## login again
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
    $m->content_like(qr/welcome administration/i);
    ok(! $m->find_link(text => 'Login'));
    ok($m->find_link(text => 'Logout'));
};

1;