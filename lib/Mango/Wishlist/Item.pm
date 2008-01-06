# $Id$
package Mango::Wishlist::Item;
use strict;
use warnings;

BEGIN {
    use base qw/Handel::Cart::Item/;
    use Handel::Constraints ();
    use DateTime ();
};
__PACKAGE__->storage->setup({
    autoupdate       => 0,
    currency_class   => 'Mango::Currency',
    schema_class     => 'Mango::Schema',
    schema_source    => 'WishlistItems',
    constraints      => {
        quantity     => {'Check Quantity' => \&Handel::Constraints::constraint_quantity}
    },
    default_values   => {
        quantity     => 1,
        created      => sub {DateTime->now},
        updated      => sub {DateTime->now}
    }
});
__PACKAGE__->result_iterator_class('Mango::Iterator');
__PACKAGE__->create_accessors;

sub price {
    return Mango::Currency->new(shift->result->get_column('price') || 0);
};

sub update {
    my $self = shift;

    $self->updated(DateTime->now);

    return $self->SUPER::update(@_);
};

sub total {
    my $self = shift;

    return Mango::Currency->new(
        ($self->result->get_column('price') || 0)*$self->quantity
    );
};

1;
__END__

=head1 NAME

Mango::Wishlist::Item - Module representing an individual wishlist item

=head1 SYNOPSIS

    my $items = $wishlist->items;
    
    while (my $item = $items->next) {
        print $item->sku;
    };

=head1 DESCRIPTION

Mango::Wishlist::Item represents an individual wishlist item.

=head1 METHODS

=head2 created

Returns the date and time in UTC the wishlist item was created as a DateTime
object.

    print $item->created;

=head2 description

=over

=item Arguments: $description

=back

Gets/sets the description for the current wishlist item.

    $item->description('Best Item Ever');
    print $item->description;

=head2 id

Returns the id of the current wishlist item.

    print $item->id;

=head2 sku

=over

=item Arguments: $sku

=back

Gets/sets the sku (stock keeping unit/part number) for the wishlist item.

    $item->sku('ABC123');
    print $item->sku;

=head2 price

=over

=item Arguments: $price

=back

Gets/sets the price for the current wishlist item. The price is returned as a
L<Mango::Currency|Mango::Currency> object.

    $item->price(12.95);
    print $item->price;
    print $item->price->format;

=head2 quantity

=over

=item Arguments: $quantity

=back

Gets/sets the quantity, or the number of this item being purchased.

    $item->quantity(3);
    print $item->quantity;

=head2 total

Returns the total price for the wishlist item as a
L<Mango::Currency|Mango::Currency> object. This is really just quantity*total
and is provided for convenience.

    print $item->total;
    print $item->total->format;

=head2 update

Saves any changes made to the wishlist item back to the provider.

    $item->quantity(2);
    $item->update;

Whenever L</update> is called, L</updated> is automatically set to the
current time in UTC.

=head2 updated

Returns the date and time in UTC the wishlist item was last updated as a
DateTime object.

    print $item->updated;

=head1 SEE ALSO

L<Mango::Wishlist>, L<Mango::Schema::Wishlist::Item>, L<Mango::Currency>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
