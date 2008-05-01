# $Id$
package Mango::Tests::Catalyst::Wishlists::Path;
use strict;
use warnings;

BEGIN {
    use base 'Mango::Tests::Catalyst::Wishlists';

    use Test::More;
}

sub config {
    { 'Controller::Wishlists' => { path => shift->path } };
}

sub path {'favorites'};

1;
