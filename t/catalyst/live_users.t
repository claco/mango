#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 1;
    use Path::Class 'file';

    Mango::Test->mk_app;
};


{
    my $m = Test::WWW::Mechanize::Catalyst->new;

};