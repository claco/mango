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

sub tests : Test(39) {
    my $self = shift;
    my $m = $self->client;

    ## not logged in
    $m->get_ok('http://localhost/');
    $self->validate_markup($m->content);
    $m->follow_link_ok({text => 'Login'});
    $m->title_like(qr/login/i);
    $m->content_unlike(qr/already logged in/i);
    $m->content_unlike(qr/welcome anonymous/i);
    ok(! $m->find_link(text => 'Logout'));
    ok(! $m->find_link(text => 'Profile'));
    $self->validate_markup($m->content);

    ## login
    $m->submit_form_ok({
        form_id => 'login',
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
    $self->validate_markup($m->content);


    ## edit profile
    $m->follow_link_ok({text => 'Profile'});
    is($m->uri->path, '/' . $self->path . '/profile/');
    $m->title_like(qr/profile/i);
    $self->validate_markup($m->content);
    $m->submit_form_ok({
        form_id => 'settings_profile',
        fields    => {
            password => 'admin',
            confirm_password => 'admin',
            first_name => 'Administration',
            last_name => 'User'
        }
    });
    $m->title_like(qr/profile/i);
    $m->content_like(qr/welcome administration/i);
    $self->validate_markup($m->content);


    ## logout
    $m->follow_link_ok({text => 'Logout'});
    $m->content_like(qr/logout successful/i);
    $m->content_unlike(qr/welcome administration/i);
    ok($m->find_link(text => 'Login'));
    ok(! $m->find_link(text => 'Logout'));
    $self->validate_markup($m->content);

    ## login again
    $m->follow_link_ok({text => 'Login'});
    $self->validate_markup($m->content);
    $m->submit_form_ok({
        form_id => 'login',
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
    $self->validate_markup($m->content);
};

1;