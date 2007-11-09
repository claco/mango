# $Id$
package Mango::Catalyst::Plugin::Authentication;
use strict;
use warnings;
our $VERSION = $Mango::VERSION;

BEGIN {
    use base qw/Catalyst::Plugin::Authentication Catalyst::Plugin::Authentication::Credential::HTTP/;

    use Mango ();
    use Mango::I18N ();
};

sub user {
    my $c = shift;
    my $default = $c->config->{'authentication'}{'default_realm'};
    my $realm = $c->get_auth_realm('mango');

    if (my $user = $c->NEXT::user(@_)) {
        return $user;
    } else {
        if (!$realm) {
            $c->log->warn(Mango::I18N::translate('REALM_NOT_FOUND'));
        } elsif ($default ne 'mango') {
            $c->log->warn(Mango::I18N::translate('REALM_NOT_MANGO'));
        } else {
            return $realm->{'store'}->anonymous_user($c);
        };
    };

    return;
};

sub is_admin {
    my $c = shift;
    my $role = $c->config->{'mango'}->{'admin_role'} || 'admin';

    return $c->check_user_roles($role);
};

sub unauthorized {
    my $c = shift;

    $c->response->status(401);
    $c->stash->{'template'} = 'errors/401';
    $c->authorization_required(realm => $c->config->{'authentication'}->{'default_realm'});
    $c->detach;
};

1;
__END__

=head1 NAME

Mango::Catalyst::Plugin::Authentication - Custom Catalyst Authentication Plugin

=head1 SYNOPSIS

    use Catalyst qw/
        -Debug
        ConfigLoader
        +Mango::Catalyst::Plugin::Authentication
        Static::Simple
    /;

=head1 DESCRIPTION

Mango::Catalyst::Plugin::Authentication is a subclass of
Catalyst::Plugin::Authentication that attempts to present authenticated and
anonymous user information in the same way:

    # anonymous user
    $c->user->username;             # anonymous
    $c->user->profile->first_name   # Anonymous
    $c->user->cart->count;
    
    # authenticated user
    $c->user->username;             # claco
    $c->user->profile->first_name   # Christopher
    $c->user->cart->count;

When authenticating users, the C<mango> realm will be used, which in turn uses
Mango::Catalyst::Plugin::Authentication::Store to authenticate users.

=head1 CONFIGURATION

The following configuration is considered the default when loading
Mango::Catalyst::Plugin::Authentication:

    authentication:
      default_realm: mango
      realms:
        mango:
          credential:
            class: Password
            password_field: password
            password_type: clear
          store:
            class: +Mango::Catalyst::Plugin::Authentication::Store
            cart_model: Carts
            profile_model: Profiles
            role_model: Roles
            user_model: Users

If the C<default_realm> is not C<mango> or no realm named C<mango> is
configured, all calls to L</user> simply return what the normal authentication
process would return. For now, this means that any piece of code relying on the
Mango specific helpers (c->user->cart, etc) will crash and burn. This may be
fixed in later release with some elfin magic.

See L<Mango::Catalyst::Plugin::Authentication::Store> for further information
about what the available configuration options mean.

=head1 METHODS

=head2 user

Returns a Mango authentication user object for the current web user. If the
current user isn't authenticated, an AnonymousUser object will be returned.
If the user has just been authenticated, a User object will be returned. If
the current user has already been authenticated, a CachedUser will be
returned.

    ## AnonymousUser pre auth
    my $user = $c->user;
    
    ## User from auth
    my $user = $c->authenticate(...);
    
    ## CachedUser after auth
    my $user = $c->user;

See the L<User|Mango::Catalyst::Plugin::Authentication::User>,
L<CachedUser|Mango::Catalyst::Plugin::Authentication::CachedUser> and
L<AnonymousUser|Mango::Catalyst::Plugin::Authentication::AnonymousUser>
for more information about the difference between the different user classes.

=head1 SEE ALSO

L<Catalyst::Plugin::Authentication>,
L<Mango::Catalyst::Plugin::Authentication::Store>
L<Mango::Catalyst::Plugin::Authentication::User>
L<Mango::Catalyst::Plugin::Authentication::CachedUser>
L<Mango::Catalyst::Plugin::Authentication::AnonymousUser>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
