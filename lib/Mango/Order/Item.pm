# $Id$
package Mango::Order::Item;
use strict;
use warnings;

BEGIN {
    use base qw/Handel::Order::Item/;
    use Handel::Constraints ();
    use DateTime ();
};
__PACKAGE__->storage->setup({
    autoupdate       => 0,
    schema_class     => 'Mango::Schema',
    schema_source    => 'OrderItems',
    currency_columns => [qw/price total/],
    constraints      => {
        quantity     => {'Check Quantity' => \&Handel::Constraints::constraint_quantity},
        price        => {'Check Price'    => \&Handel::Constraints::constraint_price},
        total        => {'Check Total'    => \&Handel::Constraints::constraint_price}
    },
    default_values   => {
        price        => 0,
        quantity     => 1,
        total        => 0
    }
});
__PACKAGE__->result_iterator_class('Mango::Iterator');
__PACKAGE__->create_accessors;

sub update {
    my $self = shift;

    $self->updated(DateTime->now);
  
    return $self->SUPER::update(@_);
};

=head1 NAME

Mango::Order::Item - Order Item Class

=head1 SYNOPSIS

    use Mango::Order::Item;
    
    my $items = $order->items;
    while (my $item = $items->next) {
        print $item->sku;
    };

=head1 DESCRIPTION

My Order Item Class

=head1 AUTHOR

    Author <author@example.com>

=cut

1;
