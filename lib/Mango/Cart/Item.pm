# $Id: Item.pm 1717 2007-02-05 02:58:52Z claco $
package Mango::Cart::Item;
use strict;
use warnings;

BEGIN {
    use base qw/Handel::Cart::Item/;
    use Handel::Constraints ();
    use DateTime ();
    #use XML::Feed::Entry ();
};
__PACKAGE__->storage->setup({
    autoupdate       => 0,
    currency_class   => 'Mango::Currency',
    schema_class     => 'Mango::Schema',
    schema_source    => 'CartItems',
    currency_columns => [qw/price/],
    constraints      => {
        quantity     => {'Check Quantity' => \&Handel::Constraints::constraint_quantity},
        price        => {'Check Price'    => \&Handel::Constraints::constraint_price}
    },
    default_values   => {
        price        => 0,
        quantity     => 1,
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

#sub as_entry {
#    my ($self, $format) = @_;
#    my $entry  = XML::Feed::Entry->new($format);
#
#    $entry->id($self->id);
#    $entry->title($self->sku);
#    #$entry->content($self->description);
#    $entry->summary($self->description);
#    $entry->category('cart');
#    $entry->issued($self->created);
#    $entry->modified($self->updated);
#
#    return $entry;
#};

1;
__END__

=head1 NAME

Mango::Cart::Item - Module representing an individual shopping cart item

=head1 SYNOPSIS

    use Mango::Cart::Item;
    
    my $items = $cart->items;
    while (my $item = $items->next) {
        print $item->sku;
    };

=head1 DESCRIPTION

Mango::Cart::Item represent a part in the shopping cart to be ordered.

=head1 METHODS

=head2 id

Returns the id of the current cart item.

    print $item->id;

=head2 sku

=over

=item Arguments: $sku

=back

Gets/sets the sku (stock keeping unit/part number) for the cart item.

    $item->sku('ABC123');
    print $item->sku;

=head2 quantity

=over

=item Arguments: $quantity

=back

Gets/sets the quantity, or the number of this item being purchased.

    $item->quantity(3);
    print $item->quantity;

=head2 price

=over

=item Arguments: $price

=back

Gets/sets the price for the cart item. The price is returned as a stringified
L<Mango::Currency|Mango::Currency> object.

    $item->price(12.95);
    print $item->price;
    print $item->price->format;

=head2 total

Returns the total price for the cart item as a stringified
L<Mango::Currency|Mango::Currency> object. This is really just
quantity*total and is provided for convenience.

    print $item->total;
    print $item->total->format;

=head2 description

=over

=item Arguments: $description

=back

Gets/sets the description for the current cart item.

    $item->description('Best Item Ever');
    print $item->description;

=head2 update

Saves any changes made to the current item.

=head1 SEE ALSO

L<Mango::Cart>, L<Mango::Schema::Cart::Item>, L<Mango::Currency>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
