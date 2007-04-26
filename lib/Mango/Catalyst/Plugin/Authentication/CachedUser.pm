# $Id: CachedUser.pm 1668 2007-01-22 04:09:47Z claco $
package Mango::Catalyst::Plugin::Authentication::CachedUser;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Plugin::Authentication::User/;
};
__PACKAGE__->mk_accessors(qw/password/);

sub new {
    my ($class, $store, $user, $roles) = @_;

    return bless {store => $store, user => $user, roles => $roles}, $class;
};

sub roles {
    my $self = shift;

    return @{$self->{'roles'} || []};
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
