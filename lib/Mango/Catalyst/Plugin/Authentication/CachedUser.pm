# $Id$
package Mango::Catalyst::Plugin::Authentication::CachedUser;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Plugin::Authentication::User/;
};
__PACKAGE__->mk_accessors(qw/password _roles/);

sub roles {
    my $self = shift;

    return @{$self->_roles || []};
};

sub supported_features {
    my $self = shift;

    return {
        roles => 1,
        profiles => 1,
        carts => 1
    };
};

1;
__END__

=head1 NAME

Mango::Catalyst::Plugin::Authentication::CachedUser - Cached Custom Catalyst Authentication User

=head1 SYNOPSIS

    use Catalyst qw/
        -Debug
        ConfigLoader
        +Mango::Catalyst::Plugin::Authentication
        Static::Simple
    /;
    
    my $user = $c->user;
    print $user->cart->count;

=head1 DESCRIPTION

Mango::Catalyst::Plugin::Authentication::CachedUser is a custom authentication
user that has been restored from the current users session.

=head1 METHODS

=head2 roles

Returns a list containing the names of all of the roles the current user
belongs to. This method is used by L<Catalyst::Plugin::Authorization::Roles>.

These roles are loaded from the current users session and cached locally.

See L<Catalyst::Plugin::Authentication> for the usage of this method.

=head2 supported_features

Returns an anonymous hash containing the following options:

    roles => 1,
    profiles => 1,
    carts => 1

=head1 SEE ALSO

L<Catalyst::Plugin::Authentication>,
L<Mango::User>, L<Mango::Profile>, L<Mango::Cart>,
L<Mango::Catalyst::Plugin::Authentication::Store>
L<Mango::Catalyst::Plugin::Authentication::User>
L<Mango::Catalyst::Plugin::Authentication::CachedUser>
L<Mango::Catalyst::Plugin::Authentication::AnonymousUser>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
