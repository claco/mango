# $Id$
package Mango::Product;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Object/;

    __PACKAGE__->mk_group_accessors('column', qw/sku name description price/);
};

sub add_attribute {
    my ($self, $data) = @_;

    return $self->provider->create_attribute($self, $data);
};

sub attributes {
    my $self = shift;

    return $self->provider->search_attributes($self, @_);
};

1;
__END__
