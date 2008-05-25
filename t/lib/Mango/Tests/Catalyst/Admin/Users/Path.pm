# $Id$
package Mango::Tests::Catalyst::Admin::Users::Path;
use strict;
use warnings;

BEGIN {
    use base 'Mango::Tests::Catalyst::Admin::Users';

    use Test::More;
}

sub config {
    { 'Controller::Admin::Users' => { path => shift->path } };
}

sub path { 'admin/people' }

1;
