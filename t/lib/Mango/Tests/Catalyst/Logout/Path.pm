# $Id$
package Mango::Tests::Catalyst::Logout::Path;
use strict;
use warnings;

BEGIN {
    use base 'Mango::Tests::Catalyst::Logout';

    use Test::More;
}

sub config {
    { 'Controller::Logout' => { path => shift->path } };
}

sub path {'deauth'};

1;
