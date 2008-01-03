#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 4;

    Mango::Test->mk_app;
};


{
    my $m = Test::WWW::Mechanize::Catalyst->new;

    ## cart is empty
    $m->get_ok('http://localhost/');
    $m->follow_link_ok({text => 'Cart'});
    $m->title_like(qr/cart/i);
    $m->content_like(qr/cart is empty/i);
};
