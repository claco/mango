# $Id$
package Mango::Product;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Object/;

    __PACKAGE__->mk_group_accessors('column', qw/sku name description price/);
};

sub add_attribute {
    my $self = shift;

    return $self->provider->create_attribute($self, @_);
};

sub attributes {
    my $self = shift;

    return $self->provider->search_attributes($self, @_);
};

sub add_tags {
    my $self = shift;

    return $self->provider->create_tags($self, @_);
};

sub tags {
    my $self = shift;

    return $self->provider->search_tags($self, @_);
};

1;
__END__
