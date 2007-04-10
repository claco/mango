# $Id$
package Mango::Role;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Object/;

    __PACKAGE__->mk_group_accessors('column', qw/name description/);
};

*add_user = \&add_users;

sub add_users {
    my $self = shift;

    return $self->provider->add_users($self, @_);
}

*remove_user = \&remove_users;

sub remove_users {
    my $self = shift;

    return $self->provider->remove_users($self, @_);
};

1;
