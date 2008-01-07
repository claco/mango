#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test;
    use Path::Class 'file';

    plan skip_all => 'Not quite yet';
    Mango::Test->mk_app;
};


{
    my $m = Test::WWW::Mechanize::Catalyst->new;

};