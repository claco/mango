# $Id$
package Mango::Provider::Products;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider::DBIC/;
    use Mango::Exception ();
};
__PACKAGE__->result_class('Mango::Product');
__PACKAGE__->source_name('Products');

sub get_by_user {
    throw Mango::Exception('METHOD_NOT_IMPLEMENTED');
};

sub get_by_sku {
    my ($self, $sku) = @_;

    return $self->search({
        sku => $sku
    });
};

1;
__END__
