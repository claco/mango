# $Id: Object.pm 1718 2007-02-05 03:00:43Z claco $
package Mango::Object;
use strict;
use warnings;

BEGIN {
    use base qw/Class::Accessor::Grouped/;

    __PACKAGE__->mk_group_accessors('simple', qw/provider data/);
    __PACKAGE__->mk_group_accessors('column', qw/id created updated/);
};


sub new {
    my ($class, $args) = @_;

    return bless $args, $class;
};

sub get_column {
    my ($self, $column) = @_;

    return $self->data->{$column};
};

sub set_column {
    my ($self, $column, $value) = @_;

    return $self->data->{$column} = $value;
};

sub destroy {
    my $self = shift;

    return $self->provider->delete($self);
};

sub update {
    my $self = shift;

    return $self->provider->update($self);
};

1;
