# $Id$
package Mango::Tests::Catalyst::Login::Path;
use strict;
use warnings;

BEGIN {
    use base 'Mango::Tests::Catalyst::Login';

    use Test::More;
}

sub config {
    { 'Controller::Login' => { path => shift->path } };
}

sub path {'auth'};

1;
