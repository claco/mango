# $Id$
package Mango::Tests::Catalyst::Users::Rename;
use strict;
use warnings;

BEGIN {
    use base 'Mango::Tests::Catalyst::Users';

    use Test::More;
    use Path::Class ();
}

sub config_application {
    my $self = shift;

    my $cfile = Path::Class::file($self->application, 'lib', 'TestApp', 'Controller', 'Users.pm');
    my $cifile = Path::Class::file($self->application, 'lib', 'TestApp', 'Controller', 'Users', 'Wishlists.pm');

    my $ncfile = Path::Class::file($self->application, 'lib', 'TestApp', 'Controller', 'People.pm');
    my $ncifile = Path::Class::file($self->application, 'lib', 'TestApp', 'Controller', 'People', 'Wishlists.pm');

    my $ccontents = $cfile->slurp;
    my $cicontents = $cifile->slurp;
        
    $ccontents =~ s/package TestApp::Controller::Users;/package TestApp::Controller::People;/;
    $cicontents =~ s/package TestApp::Controller::Users::Wishlists;/package TestApp::Controller::People::Wishlists;/;

    $cfile->remove;
    $cifile->dir->rmtree;

    $ncfile->openw->print($ccontents);
    $ncifile->dir->mkpath;
    $ncifile->openw->print($cicontents);
}

sub path {'people'};

1;
