#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 14;
    use Path::Class 'file';

    Mango::Test->mk_app;
};


{
    my $m = Test::WWW::Mechanize::Catalyst->new;


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
};