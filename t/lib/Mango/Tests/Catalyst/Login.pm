# $Id$
package Mango::Tests::Catalyst::Login;
use strict;
use warnings;

BEGIN {
    use base 'Mango::Test::Class';

    use Test::More;
    use Path::Class ();
}

sub path {'login'};

sub tests : Test(31) {
    my $self = shift;
    my $m = $self->client;

    ## not logged in
    $m->get_ok('http://localhost/');
    $m->follow_link_ok({text => 'Login'});
    $m->title_like(qr/login/i);
    is($m->uri->path, '/' . $self->path . '/');
    $m->content_unlike(qr/already logged in/i);
    $m->content_unlike(qr/welcome anonymous/i);
    ok(! $m->find_link(text => 'Logout'));


    ## empty username/password
    $m->submit_form_ok({
        form_name => 'login',
        fields    => {
            username => undef,
            password => undef
        }
    });
    $m->title_like(qr/login/i);
    $m->content_like(qr/username field is required/i);
    $m->content_like(qr/password field is required/i);
    ok(! $m->find_link(text => 'Logout'));


    ## fail login
    $m->submit_form_ok({
        form_name => 'login',
        fields    => {
            username => 'foo',
            password => 'bar'
        }
    });
    $m->title_like(qr/login/i);
    $m->content_like(qr/username or password.*incorrect/i);
    ok(! $m->find_link(text => 'Logout'));


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


    ## no form, already logged in
    $m->reload;
    {
        local $SIG{__WARN__} = sub {};
        ok(! $m->form_with_fields(qw/username password/));
    };
    $m->title_like(qr/login/i);
    $m->content_like(qr/already logged in/i);
    ok($m->find_link(text => 'Logout'));


    ## logout
    $m->follow_link_ok({text => 'Logout'});
    $m->content_like(qr/logout successful/i);
    $m->content_unlike(qr/welcome admin/i);
    ok($m->find_link(text => 'Login'));
    ok(! $m->find_link(text => 'Logout'));
};

sub tests_not_found : Test(1) {
    my $self = shift;
    my $m = $self->client;

    $m->get('http://localhost/login/');

    if ($self->path eq 'login') {
        is( $m->status, 200 );
    } else {
        is( $m->status, 404 );
    }
}

1;