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
    currency_class   => 'Mango::Currency',
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
        total        => 0,
        created      => sub {DateTime->now},
        updated      => sub {DateTime->now}
    }
});
__PACKAGE__->result_iterator_class('Mango::Iterator');
__PACKAGE__->create_accessors;

sub update {
    my $self = shift;

    $self->updated(DateTime->now);
  
    return $self->SUPER::update(@_);
};

1;
__END__

=head1 NAME

Mango::Order::Item - Module representing an individual order item

=head1 SYNOPSIS

    use Mango::Order::Item;
    
    my $items = $order->items;
    while (my $item = $items->next) {
        print $item->sku;
    };

=head1 DESCRIPTION

Mango::Order::Item represents a part in the order.

=head1 METHODS

=head2 id

Returns the id of the current order item.

    print $item->id;

=head2 sku

=over

=item Arguments: $sku

=back

Gets/sets the sku (stock keeping unit/part number) for the order item.

    $item->sku('ABC123');
    print $item->sku;

=head2 quantity

=over

=item Arguments: $quantity

=back

Gets/sets the quantity, or the number of this item.

    $item->quantity(3);
    print $item->quantity;

=head2 price

=over

=item Arguments: $price

=back

Gets/sets the price for the order item. The price is returned as a stringified
L<Mango::Currency|Mango::Currency> object.

    $item->price(12.95);
    print $item->price;
    print $item->price->format;

=head2 total

Returns the total price for the order item as a stringified
L<Mango::Currency|Mango::Currency> object. This is really just
quantity*total and is provided for convenience.

    print $item->total;
    print $item->total->format;

=head2 description

=over

=item Arguments: $description

=back

Gets/sets the description for the current order item.

    $item->description('Best Item Ever');
    print $item->description;

=head2 update

Saves any changes made to the current item.

=head1 SEE ALSO

L<Mango::Order>, L<Mango::Schema::Order::Item>, L<Mango::Currency>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
