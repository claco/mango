# $Id$
package Mango::Catalyst::Controller::Login;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
    use Mango       ();
    use Path::Class ();

    __PACKAGE__->config(
        resource_name => 'mango/login',
        form_directory =>
          Path::Class::Dir->new( Mango->share, 'forms', 'login' )
    );
}

sub login : Chained('/') PathPrefix Args(0) Form('login')
  Template('login/index') {
    my ( $self, $c ) = @_;
    my $form = $self->form;

    if ( $c->user_exists ) {
        $c->stash->{'errors'} = [ $c->localize('ALREADY_LOGGED_IN') ];
    } else {
        if ( $self->submitted && $self->validate->success ) {
            if (
                $c->authenticate(
                    {
                        username => $c->request->param('username'),
                        password => $c->request->param('password')
                    }
                )
              )
            {
                $c->stash->{'errors'} = [ $c->localize('LOGIN_SUCCEEDED') ];
            } else {
                $c->stash->{'errors'} = [ $c->localize('LOGIN_FAILED') ];
            }
        }
    }

    return;
}

1;
__END__

=head1 NAME

Mango::Catalyst::Controller::Login - Catalyst controller for logins

=head1 SYNOPSIS

    package MyApp::Controller::Login;
    use base 'Mango::Catalyst::Controller::Login';

=head1 DESCRIPTION

Mango::Catalyst::Controller::Login provides the web interface for
logging into the site.

=head1 ACTIONS

=head2 index : /login/

Authenticates the current user using the supplied username/password.

=head1 SEE ALSO

L<Mango::Catalyst::Plugin::Authentication>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/

