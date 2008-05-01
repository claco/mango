# $Id$
package Mango::Tests::Catalyst::Users::Path;
use strict;
use warnings;

BEGIN {
    use base 'Mango::Tests::Catalyst::Users';

    use Test::More;
}

sub config {
    { 'Controller::Users' => { path => shift->path } };
}

sub path {'people'};

1;
