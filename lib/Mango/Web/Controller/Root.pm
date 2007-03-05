# $Id$
package Mango::Web::Controller::Root;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::Controller/;
};

__PACKAGE__->config->{namespace} = '';

sub default : Private {
    my ($self, $c) = @_;

    $c->response->status(404);
    $c->stash->{'template'} = 'errors/404';
};

sub index : Private {
    my ($self, $c) = @_;

};

sub end : ActionClass('RenderView') {}

1;
__END__

=head1 NAME

Mango::Web::Controller::Root - Root Controller for Mango::Web

=head1 SYNOPSIS

    script/mango_web_server.pl
    
    http://localhost:3000/

=head1 DESCRIPTION

Mango::Web::Controller::Root is loaded by Mango::Web.

=head1 METHODS

=head2 default

Returns a 404 Not Found page.

=head2 index



=head2 end

Renders pages using Mango::Web::View::TT.

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
