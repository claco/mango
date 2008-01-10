# $Id$
package Mango::Cart;
use strict;
use warnings;

BEGIN {
    use base qw/Handel::Cart/;
    use Mango::User ();
    use Mango::Exception ();
    use DateTime ();
    use Scalar::Util ();
};

## Yes, this isn't the preferred way. Sue me. I don't want the storage classes
## floating around this dist. If you make your own cart, feel free to do it the
## correct way. ;-)
__PACKAGE__->item_class('Mango::Cart::Item');
__PACKAGE__->storage->setup({
    autoupdate         => 0,
    currency_class     => 'Mango::Currency',
    schema_class       => 'Mango::Schema',
    schema_source      => 'Carts',
    constraints        => undef,
    default_values     => {
        created        => sub {DateTime->now},
        updated        => sub {DateTime->now}
    },
    validation_profile => undef
});
__PACKAGE__->result_iterator_class('Mango::Iterator');
__PACKAGE__->create_accessors;

sub name {};

sub description {};

sub type {
    Mango::Exception->throw('METHOD_NOT_IMPLEMENTED');
};

sub save {
    Mango::Exception->throw('METHOD_NOT_IMPLEMENTED');
};

sub user {
    my ($self, $user) = @_;

    if (defined $user) {
        if (Scalar::Util::blessed $user) {
            if ($user->isa('Mango::User')) {
                $user = $user->id;
            } else {
                Mango::Exception->throw('NOT_A_USER');
            };
        };

        $self->user_id($user);
    } else {
        Mango::Exception->throw('NO_USER_SPECIFIED');
    };
};

sub update {
    my $self = shift;

    $self->updated(DateTime->now);
  
    return $self->SUPER::update(@_);
};

1;
__END__

=head1 NAME

Mango::Cart - Module representing a shopping cart

=head1 SYNOPSIS

    my $cart = $provider->create({
        user => 23
    });
    
    $cart->add({
        sku      => 'SKU1234',
        quantity => 1,
        price    => 1.25
    });
    
    my $items = $cart->items;
    while (my $item = $items->next) {
        print $item->sku;
        print $item->price;
        print $item->total;
    };
    print $cart->subtotal;

=head1 DESCRIPTION

Mango::Cart represents a users shopping cart and cart contents.

=head1 METHODS

=head2 add

=over

=item Arguments: \%data | $item

=back

Adds a new item to the current shopping cart and returns the new item. You can
pass in the item data as a hash reference:

    my $item = $cart->add({
        sku      => 'SKU1234',
        quantity => 1,
        price    => 1.25
    });

or pass an existing cart item:

    $cart->add(
        $wishlist->items({sku => 'ABC-123'})->first
    );

When passing an existing cart item to add, all columns in the source item will
be copied into the destination item if the column exists in the destination and
the column isn't the primary key or the foreign key of the item relationship.

The item object passed to add must be an instance or subclass of Handel::Cart.

=head2 clear

Deletes all items from the current cart.

    $cart->clear;

=head2 count

Returns the number of items in the cart.

    my $numitems = $cart->count;

=head2 created

Returns the date and time in UTC the cart was created as a DateTime object.

    print $cart->created;

=head2 delete

=over

=item Arguments: \%filter

=back

Deletes the item(s) matching the supplied filter from the current cart.

    $cart->delete({
        sku => 'ABC-123'
    });

=head2 destroy

Deletes the current cart and all of its items.

=head2 id

Returns the id of the current cart.

    print $cart->id;

=head2 items

=over

=item Arguments: \%filter [, \%options]

=back

Loads the current carts items matching the specified filter and returns a
L<Mango::Iterator|Mango::Iterator> in scalar context, or a list of items in
list context.

    my $iterator = $cart->items;
    
    while (my $item = $iterator->next) {
        print $item->sku;
    };
    
    my @items = $cart->items;

The following options are available:

=over

=item order_by

Order the items by the column(s) and order specified. This option uses the SQL
style syntax:

    my $items = $cart->items(undef, {order_by => 'sku ASC'});

=back

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

    my $wishlist = Mango::Wishlist->search({
        id   => 23
    })->first;
    
    $cart->restore($wishlist);

For either method, you may also specify the mode in which the cart should be
restored. The following modes are available:

=over

=item C<CART_MODE_REPLACE>

All items in the current cart will be deleted before the saved cart is restored
into it. This is the default if no mode is specified.

=item C<CART_MODE_MERGE>

If an item with the same SKU exists in both the current cart and the saved
cart/wishlist, the quantity of each will be added together and applied to
the same sku in the current cart. Any price differences are ignored and we
assume that the price in the current cart has the more up to date price.

=item C<CART_MODE_APPEND>

All items in the saved cart will be appended to the list of items in the current
cart. No effort will be made to merge items with the same SKU and duplicates
will be allowed.

=back

=head2 subtotal

Returns the current total price of all the items in the cart as a
L<Mango::Currency|Mango::Currency> object. This is equivalent to:

    my $items = $cart->items;
    my $subtotal = 0;
    
    while (my $item = $items->next) {
        $subtotal += $item->quantity*$item->price;
    };

=head2 update

Saves any changes made to the cart back to the provider.

    $cart->user(23);
    $cart->update;

Whenever L</update> is called, L</updated> is automatically set to the
current time in UTC.

=head2 updated

Returns the date and time in UTC the cart was last updated as a DateTime
object.

    print $cart->updated;

=head2 user

=over

=item Arguments: $user

=back

Assigns the current cart to the specified user. This can be a Mango::User
object or the user id.

=head1 SEE ALSO

L<Mango::Cart::Item>, L<Mango::Schema::Cart>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
