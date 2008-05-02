# $Id$
package Mango::Tests::Catalyst::Products::Rename;
use strict;
use warnings;

BEGIN {
    use base 'Mango::Tests::Catalyst::Products';

    use Test::More;
    use Path::Class ();
}

sub config_application {
    my $self = shift;

    my $cfile = Path::Class::file($self->application, 'lib', 'TestApp', 'Controller', 'Products.pm');
    my $ncfile = Path::Class::file($self->application, 'lib', 'TestApp', 'Controller', 'Catalog.pm');
    my $contents = $cfile->slurp;
        
    $contents =~ s/package TestApp::Controller::Products;/package TestApp::Controller::Catalog;/;

    $cfile->remove;
    $ncfile->openw->print($contents);
}

sub path {'catalog'};

1;
