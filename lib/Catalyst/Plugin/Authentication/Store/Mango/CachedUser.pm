# $Id$
package Catalyst::Plugin::Authentication::Store::Mango::CachedUser;
use strict;
use warnings;
use overload '""' => sub {shift->id}, fallback => 1;

BEGIN {
    use base qw/Catalyst::Plugin::Authentication::Store::Mango::User/;
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
        profiles => 1
    };
};

1;
__END__
