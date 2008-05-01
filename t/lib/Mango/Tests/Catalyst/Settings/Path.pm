# $Id$
package Mango::Tests::Catalyst::Settings::Path;
use strict;
use warnings;

BEGIN {
    use base 'Mango::Tests::Catalyst::Settings';

    use Test::More;
}

sub config {
    { 'Controller::Settings' => { path => shift->path } };
}

sub path {'preferences'};

1;
