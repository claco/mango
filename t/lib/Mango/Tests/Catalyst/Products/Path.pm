# $Id$
package Mango::Tests::Catalyst::Products::Path;
use strict;
use warnings;

BEGIN {
    use base 'Mango::Tests::Catalyst::Products';

    use Test::More;
}

sub config {
    { 'Controller::Products' => { path => shift->path } };
}

sub path {'parts'};

1;
