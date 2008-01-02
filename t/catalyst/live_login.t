#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 23;

    Mango::Test->mk_app;
};


{
    my $m = Test::WWW::Mechanize::Catalyst->new;

    ## not logged in
    $m->get_ok('http://localhost/');
    $m->follow_link_ok({text => 'Login'});
    $m->title_like(qr/login/i);
    $m->content_unlike(qr/already logged in/i);
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
};
