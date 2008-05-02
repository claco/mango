# $Id$
package Mango::Tests::Catalyst::Wishlists::Rename;
use strict;
use warnings;

BEGIN {
    use base 'Mango::Tests::Catalyst::Wishlists';

    use Test::More;
    use Path::Class ();
}

sub config_application {
    my $self = shift;

    my $cfile = Path::Class::file($self->application, 'lib', 'TestApp', 'Controller', 'Wishlists.pm');
    my $cifile = Path::Class::file($self->application, 'lib', 'TestApp', 'Controller', 'Wishlists', 'Items.pm');

    my $ncfile = Path::Class::file($self->application, 'lib', 'TestApp', 'Controller', 'Favorites.pm');
    my $ncifile = Path::Class::file($self->application, 'lib', 'TestApp', 'Controller', 'Favorites', 'Items.pm');

    my $ccontents = $cfile->slurp;
    my $cicontents = $cifile->slurp;
        
    $ccontents =~ s/package TestApp::Controller::Wishlists;/package TestApp::Controller::Favorites;/;
    $cicontents =~ s/package TestApp::Controller::Wishlists::Items;/package TestApp::Controller::Favorites::Items;/;

    $cfile->remove;
    $cifile->dir->rmtree;

    $ncfile->openw->print($ccontents);
    $ncifile->dir->mkpath;
    $ncifile->openw->print($cicontents);
}

sub path {'favorites'};

1;
