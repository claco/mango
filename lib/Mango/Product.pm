# $Id$
package Mango::Product;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Object/;

    __PACKAGE__->mk_group_accessors('column', qw/sku name description price/);
};

sub add_attribute {
    return shift->add_attributes(@_);
};

sub add_attributes {
    my $self = shift;

    return $self->provider->add_attributes($self, @_);
};

sub attributes {
    my $self = shift;

    return $self->provider->search_attributes($self, @_);
};

sub delete_attributes {
    my $self = shift;

    return $self->provider->delete_attributes($self, @_);
};

sub add_tag {
    return shift->add_tags(@_);
};

sub add_tags {
    my $self = shift;

    return $self->provider->add_tags($self, @_);
};

sub tags {
    my $self = shift;

    return $self->provider->search_tags($self, @_);
};

sub delete_tags {
    my $self = shift;

    return $self->provider->delete_tags($self, @_);
};

1;
__END__
