#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 7;
    use Path::Class 'file';

    Mango::Test->mk_app;
};


{
    my $m = Test::WWW::Mechanize::Catalyst->new;


    ## users not found
    $m->get('http://localhost/users/');
    is($m->status, 404);
    $m->content_like(qr/resource.*not found/i);


    ## invalid user not found
    $m->get('http://localhost/users/claco/');
    is($m->status, 404);
    $m->content_like(qr/user.*not.*found/i);


    ## real user
    $m->get_ok('http://localhost/users/admin/');
    $m->title_like(qr/admin\'s profile/i);
    $m->content_contains('Admin User');
};