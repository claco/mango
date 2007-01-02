package Mango::Setup::Controller::Root;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::Controller/;
};

__PACKAGE__->config->{namespace} = '';

sub default : Private {
    my ($self, $c) = @_;

    $c->res->status(404);
    $c->stash->{'template'} = 'errors/404';
};

sub index : Private {
    my ($self, $c) = @_;

    $c->res->redirect($c->uri_for('/setup/'));
};

sub end : ActionClass('RenderView') {}

1;
__END__

=head1 NAME

Mango::Setup::Controller::Root - Root Controller for Mango::Setup

=head1 SYNOPSIS

    script/mango_setup_server.pl
    
    http://localhost:3000/

=head1 DESCRIPTION

Mango::Setup::Controller::Root is loaded by Mango::Setup.

=head1 METHODS

=head2 default

Returns a 404 Not Found page.

=head2 index

Redirects to /setup/.

=head2 end

Renders pages using Mango::Setup::View::TT.

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
