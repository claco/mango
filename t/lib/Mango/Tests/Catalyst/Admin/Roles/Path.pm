# $Id$
package Mango::Tests::Catalyst::Admin::Roles::Path;
use strict;
use warnings;

BEGIN {
    use base 'Mango::Tests::Catalyst::Admin::Roles';

    use Test::More;
}

sub config {
    { 'Controller::Admin::Roles' => { path => shift->path } };
}

sub path { 'admin/groups' }

1;
