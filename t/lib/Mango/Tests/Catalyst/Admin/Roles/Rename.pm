# $Id$
package Mango::Tests::Catalyst::Admin::Roles::Rename;
use strict;
use warnings;

BEGIN {
    use base 'Mango::Tests::Catalyst::Admin::Roles';

    use Test::More;
    use Path::Class ();
}

sub config_application {
    my $self = shift;

    my $cfile = Path::Class::file($self->application, 'lib', 'TestApp', 'Controller', 'Admin', 'Roles.pm');
    my $ncfile = Path::Class::file($self->application, 'lib', 'TestApp', 'Controller', 'Admin', 'Groups.pm');
    my $contents = $cfile->slurp;
        
    $contents =~ s/package TestApp::Controller::Admin::Roles;/package TestApp::Controller::Admin::Groups;/;

    $cfile->remove;
    $ncfile->openw->print($contents);
}

sub path {'admin/groups'};

1;
