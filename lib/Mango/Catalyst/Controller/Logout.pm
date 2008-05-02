# $Id$
package Mango::Catalyst::Controller::Logout;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;

    __PACKAGE__->config( resource_name => 'mango/logout' );
}

sub logout : Chained('/') PathPrefix Args(0) Template('logout/index') {
    my ( $self, $c ) = @_;

    if ( $c->user_exists ) {
        $c->logout;
        $c->stash->{'errors'} = [ $c->localize('LOGOUT_SUCCEEDED') ];
    }

    return;
}

1;
__END__

=head1 NAME

Mango::Catalyst::Controller::Logout - Catalyst controller for logouts

=head1 SYNOPSIS

    package MyApp::Controller::Logout;
    use base 'Mango::Catalyst::Controller::Logout';

=head1 DESCRIPTION

Mango::Catalyst::Controller::Logout provides the web interface for
logging out of the site.

=head1 ACTIONS

=head2 index : /logout/

Logs the current user out of the site.

=head1 SEE ALSO

L<Mango::Catalyst::Plugin::Authentication>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/

