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
