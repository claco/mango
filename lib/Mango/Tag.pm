# $Id$
package Mango::Tag;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Object/;

    __PACKAGE__->mk_group_accessors('column', qw/name count/);
};

sub delete {
    my $self = shift;
    my $filter = shift;

    $filter ||= {};
    $filter->{'id'} = $self->id;

    return $self->provider->delete_attributes($filter, @_);
};

sub update {
    my $self = shift;

    return $self->provider->update_attribute($self);
};

1;
