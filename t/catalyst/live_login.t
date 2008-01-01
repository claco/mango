#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 12;

    Mango::Test->mk_app;
};


## GET /login
{
    my $m = Test::WWW::Mechanize::Catalyst->new;

    ## not logged in
    $m->get_ok('http://localhost/');
    $m->follow_link_ok({text => 'Login'});
    $m->title_like(qr/login/i);
    $m->content_unlike(qr/already logged in/i);

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

    ## login again yields already logged in
    $m->submit_form_ok({
        form_name => 'login',
        fields    => {
            username => 'foo',
            password => 'bar'
        }
    });
    $m->title_like(qr/login/i);
    $m->content_like(qr/already logged in/i);
};
