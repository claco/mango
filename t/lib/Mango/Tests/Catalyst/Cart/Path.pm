# $Id$
package Mango::Tests::Catalyst::Cart::Path;
use strict;
use warnings;

BEGIN {
    use base 'Mango::Tests::Catalyst::Cart';

    use Test::More;
}

sub config {
    { 'Controller::Cart' => { path => shift->path } };
}

sub path {'basket'};

1;
