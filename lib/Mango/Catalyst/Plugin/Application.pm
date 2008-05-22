# $Id$
package Mango::Catalyst::Plugin::Application;
use strict;
use warnings;
our $VERSION = $Mango::VERSION;

BEGIN {
    use base qw/
      Mango::Catalyst::Plugin::Authentication
      Mango::Catalyst::Plugin::I18N
      Mango::Catalyst::Plugin::Forms
      /;

    use URI ();
}

sub register_resource {
    my ( $self, $name, $class ) = @_;
    $class = ref $class || $class;

    $self->config->{'mango'}->{'controllers'}->{$name} = $class;

    if ( $self->debug ) {
        $self->log->debug("Registering resource $class as $name");
    }

    return;
}

sub uri_for_resource {
    my ( $self, $name, $action, @args ) = @_;
    my $class = $self->config->{'mango'}->{'controllers'}->{$name};

    if ( !$class ) {
        return;
    }

    my $controller = $self->controller( $class . '$' );
    $action = $controller->action_for( $action || 'index' );

    return $self->uri_for( $action, @args );
}

sub redirect_to_login {
    my $self = shift;

    $self->session->{'__mango_return_url'} = $self->request->uri->path_query;
    $self->response->redirect(
        $self->uri_for_resource( 'mango/login', 'login' ) . '/' );

    return;
}

sub redirect_from_login {
    my $self = shift;

    if ( $self->sessionid ) {
        my $url = $self->session->{'__mango_return_url'};

        if ($url) {
            my $uri = URI->new($url);
            delete $self->session->{'__mango_return_url'};

            $self->response->redirect( $uri->path_query );
        }
    }

    return;
}

1;
__END__

=head1 NAME

Mango::Catalyst::Plugin::Application - Catalyst plugin loading all Mango specific plugins

=head1 SYNOPSIS

    use Catalyst qw/
        -Debug
        ConfigLoader
        Mango::Catalyst::Plugin::Application
        Static::Simple
    /;

=head1 DESCRIPTION

Mango::Catalyst::Plugin::Application loads all Mango related plugins into a
Catalyst application.

=head1 METHODS

=head2 redirect_to_login

Redirects the user to the current login page, storing the current pages
uri to return to using C<redirect_from_login>.

=head2 redirect_from_login

Redirects the user back to the page they were visiting before having to login.

=head2 register_resource

=over

=item Arguments: $name, $class

=back

Associates the specified class with the given name so controllers can be
referred to by a nickname with Mango code when the class name is unknown or
may change in subclasses.

=head2 uri_for_resource

=over

=item Arguments: $name, $action, @args

=back

Looks up the class name for the specified resource and returns a uri for the
given action using C<uri_for>.

=head1 SEE ALSO

L<Mango::Catalyst::Plugin::Authentication>, L<Mango::Catalyst::Plugin::I18N>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
