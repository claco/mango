# $Id$
package Mango::Wishlist;
use strict;
use warnings;

BEGIN {
    use base qw/Handel::Cart/;
    use Handel::Constraints ();
    use DateTime            ();
}

## Yes, this isn't the preferred way. Sue me. I don't want the storage classes
## floating around this dist. If you make your own cart, feel free to do it
## the correct way. ;-)
__PACKAGE__->item_class('Mango::Wishlist::Item');
__PACKAGE__->storage->setup(
    {
        autoupdate     => 0,
        currency_class => 'Mango::Currency',
        schema_class   => 'Mango::Schema',
        schema_source  => 'Wishlists',
        constraints    => {
            name =>
              { 'Check Name' => \&Handel::Constraints::constraint_cart_name },
        },
        default_values => {
            created => sub { DateTime->now },
            updated => sub { DateTime->now }
        },
        validation_profile => undef
    }
);
__PACKAGE__->result_iterator_class('Mango::Iterator');
__PACKAGE__->create_accessors;

sub items {
    my ( $self, $filter, $options ) = @_;
    $options ||= {};

    $options->{'join'}    = 'product';
    $options->{'+select'} = 'product.price';
    $options->{'+as'}     = 'price';

    return $self->SUPER::items( $filter, $options );
}

sub type {
    Mango::Exception->throw('METHOD_NOT_IMPLEMENTED');

    return;
}

sub save {
    Mango::Exception->throw('METHOD_NOT_IMPLEMENTED');

    return;
}

sub update {
    my $self = shift;

    $self->updated( DateTime->now );

    return $self->SUPER::update(@_);
}

1;
__END__

=head1 NAME

Mango::Wishlist - Module representing a wishlist

=head1 SYNOPSIS

    my $wishlist = $provider->create({
        user => 23
    });
    
    $wishlist->add({
        sku      => 'SKU1234',
        quantity => 1,
        price    => 1.25
    });
    
    my $items = $wishlist->items;
    while (my $item = $items->next) {
        print $item->sku;
        print $item->price;
        print $item->total;
    };
    print $wishlist->subtotal;

=head1 DESCRIPTION

Mango::Wishlist represents a users wishlist and wishlist contents. A wishlist
is simply cart that has been saved and given a name for later use.

=head1 METHODS

=head2 add

=over

=item Arguments: \%data | $item

=back

Adds a new item to the current wishlist and returns the new item. You can
pass in the item data as a hash reference:

    my $item = $wishlist->add({
        sku      => 'SKU1234',
        quantity => 1,
        price    => 1.25
    });

or pass an existing wishlist/cart item:

    $wishlist->add(
        $cart->items({sku => 'ABC-123'})->first
    );

When passing an existing item to add, all columns in the source item will
be copied into the destination item if the column exists in the destination
and the column isn't the primary key or the foreign key of the item
relationship.

The item object passed to add must be an instance or subclass of Handel::Cart.

=head2 clear

Deletes all items from the current wishlist.

    $wishlist->clear;

=head2 count

Returns the number of items in the wishlist.

    my $numitems = $wishlist->count;

=head2 created

Returns the date and time in UTC the wishlist was created as a DateTime
object.

    print $wishlist->created;

=head2 delete

=over

=item Arguments: \%filter

=back

Deletes the item(s) matching the supplied filter from the current wishlist.

    $wishlist->delete({
        sku => 'ABC-123'
    });

=head2 description

=over

=item Arguments: $description

=back

Gets/sets the description of the current wishlist.

    print $wishlist->description;

=head2 destroy

Deletes the current wishlist and all of its items.

=head2 id

Returns the id of the current wishlist.

    print $wishlist->id;

=head2 items

=over

=item Arguments: \%filter [, \%options]

=back

Loads the current wishlist items matching the specified filter and returns a
L<Mango::Iterator|Mango::Iterator> in scalar context, or a list of items in
list context.

    my $iterator = $wishlist->items;
    
    while (my $item = $iterator->next) {
        print $item->sku;
    };
    
    my @items = $wishlist->items;

The following options are available:

=over

=item order_by

Order the items by the column(s) and order specified. This option uses the SQL
style syntax:

    my $items = $wishlist->items(undef, {order_by => 'sku ASC'});

=back

=head2 name

=over

=item Arguments: $name

=back

Gets/sets the name of the current wishlist.

    print $wishlist->name;

=head2 restore

=over

=item Arguments: \%filter [, $mode]

=item Arguments: $cart [, $mode]

=back

Copies (restores) items from a cart/wishlist, or a set of carts/wishlist back
into the current cart. You may either pass in a hash reference containing the
search criteria of the cart(s) to restore:

    $cart->restore({
        id => 23
    });

or you can pass in an existing C<Mango::Cart> or C<Mango::Wishlist> object
or subclass.

    my $cart = Mango::Cart->search({
        id   => 23
    })->first;
    
    $wishlist->restore($cart);

For either method, you may also specify the mode in which the wishlist should
be restored. The following modes are available:

=over

=item C<WISHLIST_MODE_REPLACE>

All items in the current wishlist will be deleted before the cart is restored
into it. This is the default if no mode is specified.

=item C<WISHLIST_MODE_MERGE>

If an item with the same SKU exists in both the current wishlist and the saved
cart, the quantity of each will be added together and applied to
the same sku in the current wishlist. Any price differences are ignored and we
assume that the price in the current wishlist has the more up to date price.

=item C<WISHLIST_MODE_APPEND>

All items in the cart will be appended to the list of items in the current
wishlist. No effort will be made to merge items with the same SKU and
duplicates will be allowed.

=back

=head2 subtotal

Returns the current total price of all the items in the wishlist as a
L<Mango::Currency|Mango::Currency> object. This is equivalent to:

    my $items = $wishlist->items;
    my $subtotal = 0;
    
    while (my $item = $items->next) {
        $subtotal += $item->quantity*$item->price;
    };

=head2 update

Saves any changes made to the wishlist back to the provider.

    $wishlist->user(23);
    $wishlist->update;

Whenever L</update> is called, L</updated> is automatically set to the
current time in UTC.

=head2 updated

Returns the date and time in UTC the wishlist was last updated as a DateTime
object.

    print $wishlist->updated;

=head1 SEE ALSO

L<Mango::Wishlist::Item>, L<Mango::Schema::Wishlist>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
