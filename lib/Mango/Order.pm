# $Id$
package Mango::Order;
use strict;
use warnings;

BEGIN {
    use base qw/Handel::Order/;
    use Handel::Constants qw/ORDER_TYPE_TEMP/;
    use Handel::Constraints ();
    use DateTime ();
};

## Yes, this isn't the preferred way. Sue me. I don't want the storage classes
## floating around this dist. If you make your own order, feel free to do it the
## correct way. ;-)
__PACKAGE__->item_class('Mango::Order::Item');
__PACKAGE__->storage->setup({
    autoupdate         => 0,
    currency_class     => 'Mango::Currency',
    schema_class       => 'Mango::Schema',
    schema_source      => 'Orders',
    currency_columns => [qw/shipping handling subtotal tax total/],
    constraints        => {
        type           => {'Check Type'     => \&Handel::Constraints::constraint_order_type},
        shipping       => {'Check Shopping' => \&Handel::Constraints::constraint_price},
        handling       => {'Check Handling' => \&Handel::Constraints::constraint_price},
        subtotal       => {'Check Subtotal' => \&Handel::Constraints::constraint_price},
        tax            => {'Check Tax'      => \&Handel::Constraints::constraint_price},
        total          => {'Check Total'    => \&Handel::Constraints::constraint_price}
    },
    default_values => {
        type     => ORDER_TYPE_TEMP,
        shipping => 0,
        handling => 0,
        subtotal => 0,
        tax      => 0,
        total    => 0,
        created  => sub {DateTime->now},
        updated  => sub {DateTime->now}
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

Mango::Order - Module for maintaining order contents

=head1 SYNOPSIS

    my $order = $provider->create({
        user => $user
    });
    
    my $iterator = $order->items;
    while (my $item = $iterator->next) {
        print $item->sku;
        print $item->price;
        print $item->total;
    };

=head1 DESCRIPTION

Mango::Order is a component for maintaining simple order records.

=head1 METHODS

=head2 add

=over

=item Arguments: \%data | $item

=back

Adds a new item to the current order and returns an instance of the item class.
You can either pass the item data as a hash reference:

    my $item = $order->add({
        sku      => 'SKU1234',
        quantity => 1,
        price    => 1.25
    });

or pass an existing item:

    $order->add(
        $cart->items->first
    );

When passing an existing cart/order item to add, all columns in the source item
will be copied into the destination item if the column exists in both the
destination and source, and the column isn't the primary key or the foreign
key of the item relationship.

=head2 clear

Deletes all items from the current order.

    $order->clear;

=head2 count

Returns the number of items in the order object.

    my $numitems = $order->count;

=head2 delete

=over

=item Arguments: \%filter

=back

Deletes the item matching the supplied filter from the current order.

    $order->delete({
        sku => 'ABC-123'
    });

=head2 destroy

Deletes the current item from the provider.

=head2 items

=over

=item Arguments: \%filter [, \%options]

=back

Loads the current orders items matching the specified filter and returns a
L<Mango::Iterator|Mango::Iterator> in scalar context, or a list of items in
list context.

    my $iterator = $order->items;
    while (my $item = $iterator->next) {
        print $item->sku;
    };
    
    my @items = $order->items;

The following options are available:

=over

=item order_by

Order the items by the column(s) and order specified. This option uses the SQL
style syntax:

    my $items = $order->items(undef, {order_by => 'sku ASC'});

=back

=head2 save

Marks the current order type as C<ORDER_TYPE_SAVED>.

    $order->save

=head2 reconcile

=over

=item Arguments: $cart

=back

This method copies the specified carts items into the order only if the item
count or the subtotal differ.

=head2 id

Returns the id of the current order.

    print $order->id;

See L<Handel::Schema::Order/id> for more information about this column.

=head2 type

=over

=item Arguments: $type

=back

Gets/sets the type of the current order. Currently the two types allowed are:

=over

=item C<ORDER_TYPE_TEMP>

The order is temporary and may be purged during any [external] cleanup process
after the designated amount of inactivity.

=item C<ORDER_TYPE_SAVED>

The order should be left untouched by any cleanup process and is available to
the shopper at any time.

=back

    $order->type(ORDER_TYPE_SAVED);
    print $order->type;

=head2 number

=over

=item Arguments: $number

=back

Gets/sets the order number.

    $order->number(1015275);
    print $order->number;

=head2 created

=over

=item $datetime

=back

Gets/sets the date/time when the order was created. The date is returned as a
stringified L<DateTime|DateTime> object.

    $order->created('2006-04-11T12:34:65');
    print $order->created;

=head2 updated

=over

=item $datetime

=back

Gets/sets the date/time when the order was last updated. The date is returned
as a stringified L<DateTime|DateTime> object.

    $order->updated('2006-04-11T12:34:65');
    print $order->updated;

=head2 comments

=over

=item $comments

=back

Gets/sets the comments for this order.

    $order->comments('Handel with care');
    print $order->comments;

=head2 shipmethod

=over

=item $shipmethod

=back

Gets/sets the shipping method for this order.

    $order->shipmethod('UPS 2nd Day');
    print $order->shipmethod;

=head2 shipping

=over

=item Arguments: $price

=back

Gets/sets the shipping cost for the order item. The price is returned as a
stringified L<Mango::Currency|Mango::Currency> object.

    $item->shipping(12.95);
    print $item->shipping;
    print $item->shipping->format;

=head2 handling

=over

=item Arguments: $price

=back

Gets/sets the handling cost for the order item. The price is returned as a
stringified L<Mango::Currency|Mango::Currency> object.

    $item->handling(12.95);
    print $item->handling;
    print $item->handling->format;

=head2 tax

=over

=item Arguments: $price

=back

Gets/sets the tax for the order item. The price is returned as a
stringified L<Mango::Currency|Mango::Currency> object.

    $item->tax(12.95);
    print $item->tax;
    print $item->tax->format;

=head2 subtotal

=over

=item Arguments: $price

=back

Gets/sets the subtotal for the order item. The price is returned as a
stringified L<Mango::Currency|Mango::Currency> object.

    $item->subtotal(12.95);
    print $item->subtotal;
    print $item->subtotal->format;

=head2 total

=over

=item Arguments: $price

=back

Gets/sets the total for the order item. The price is returned as a
stringified L<Mango::Currency|Mango::Currency> object.

    $item->total(12.95);
    print $item->total;
    print $item->total->format;

=head2 billtofirstname

=over

=item Arguments: $firstname

=back

Gets/sets the bill to first name.

    $order->billtofirstname('Chistopher');
    print $order->billtofirstname;

=head2 billtolastname

=over

=item Arguments: $lastname

=back

Gets/sets the bill to last name

    $order->billtolastname('Chistopher');
    print $order->billtolastname;

=head2 billtoaddress1

=over

=item Arguments: $address1

=back

Gets/sets the bill to address line 1

    $order->billtoaddress1('1234 Main Street');
    print $order->billtoaddress1;

=head2 billtoaddress2

=over

=item Arguments: $address2

=back

Gets/sets the bill to address line 2

    $order->billtoaddress2('Suite 34b');
    print $order->billtoaddress2;

=head2 billtoaddress3

=over

=item Arguments: $address3

=back

Gets/sets the bill to address line 3

    $order->billtoaddress3('Floor 5');
    print $order->billtoaddress3;

=head2 billtocity

=over

=item Arguments: $city

=back

Gets/sets the bill to city

    $order->billtocity('Smallville');
    print $order->billtocity;

=head2 billtostate

=over

=item Arguments: $state

=back

Gets/sets the bill to state/province

    $order->billtostate('OH');
    print $order->billtostate;

=head2 billtozip

=over

=item Arguments: $zip

=back

Gets/sets the bill to zip/postal code

    $order->billtozip('12345-6500');
    print $order->billtozip;

=head2 billtocountry

=over

=item Arguments: $country

=back

Gets/sets the bill to country

    $order->billtocountry('US');
    print $order->billtocountry;

=head2 billtodayphone

=over

=item Arguments: $phone

=back

Gets/sets the bill to day phone number

    $order->billtodayphone('800-867-5309');
    print $order->billtodayphone;

=head2 billtonightphone

=over

=item Arguments: $phone

=back

Gets/sets the bill to night phone number

    $order->billtonightphone('800-867-5309');
    print $order->billtonightphone;

=head2 billtofax

=over

=item Arguments: $fax

=back

Gets/sets the bill to fax number

    $order->billtofax('888-132-4335');
    print $order->billtofax;

=head2 billtoemail

=over

=item Arguments: $email

=back

Gets/sets the bill to email address

    $order->billtoemail('claco@chrislaco.com');
    print $order->billtoemail;

=head2 shiptosameasbillto

=over

=item Arguments: 0|1

=back

When true, the ship address is the same as the bill to address.

    $order->shiptosameasbillto(1);
    print $order->shiptosameasbillto;

=head2 shiptofirstname

=over

=item Arguments: $firstname

=back

Gets/sets the ship to first name.

    $order->shiptofirstname('Chistopher');
    print $order->shiptofirstname;

=head2 shiptolastname

=over

=item Arguments: $lastname

=back

Gets/sets the ship to last name

    $order->shiptolastname('Chistopher');
    print $order->shiptolastname;

=head2 shiptoaddress1

=over

=item Arguments: $address1

=back

Gets/sets the ship to address line 1

    $order->shiptoaddress1('1234 Main Street');
    print $order->shiptoaddress1;

=head2 shiptoaddress2

=over

=item Arguments: $address2

=back

Gets/sets the ship to address line 2

    $order->shiptoaddress2('Suite 34b');
    print $order->shiptoaddress2;

=head2 shiptoaddress3

=over

=item Arguments: $address3

=back

Gets/sets the ship to address line 3

    $order->shiptoaddress3('Floor 5');
    print $order->shiptoaddress3;

=head2 shiptocity

=over

=item Arguments: $city

=back

Gets/sets the ship to city

    $order->shiptocity('Smallville');
    print $order->shiptocity;

=head2 shiptostate

=over

=item Arguments: $state

=back

Gets/sets the ship to state/province

    $order->shiptostate('OH');
    print $order->shiptostate;

=head2 shiptozip

=over

=item Arguments: $zip

=back

Gets/sets the ship to zip/postal code

    $order->shiptozip('12345-6500');
    print $order->shiptozip;

=head2 shiptocountry

=over

=item Arguments: $country

=back

Gets/sets the ship to country

    $order->shiptocountry('US');
    print $order->shiptocountry;

=head2 shiptodayphone

=over

=item Arguments: $phone

=back

Gets/sets the ship to day phone number

    $order->shiptodayphone('800-867-5309');
    print $order->shiptodayphone;

=head2 shiptonightphone

=over

=item Arguments: $phone

=back

Gets/sets the ship to night phone number

    $order->shiptonightphone('800-867-5309');
    print $order->shiptonightphone;

=head2 shiptofax

=over

=item Arguments: $fax

=back

Gets/sets the ship to fax number

    $order->shiptofax('888-132-4335');
    print $order->shiptofax;

=head2 shiptoemail

=over

=item Arguments: $email

=back

Gets/sets the ship to email address

    $order->shiptoemail('claco@chrislaco.com');
    print $order->shiptoemail;

=head2 update

Saves any changes made to the current item.

=head1 TEMPORARY COLUMNS

The following columns are really just methods to hold sensitive 
order data that we don't want to actually store in the database.

=head2 ccn

=over

=item Arguments: $ccn

=back

Gets/sets the credit cart number.

    $order->ccn(4444333322221111);
    print $order->ccn;

=head2 cctype

=over

=item Arguments: $type

=back

Gets/sets the credit cart type.

    $order->cctype('MasterCard');
    print $order->cctype;

=head2 ccm

=over

=item Arguments: $month

=back

Gets/sets the credit cart expiration month.

    $order->ccm(1);
    print $order->ccm;

=head2 ccy

=over

=item Arguments: $year

=back

Gets/sets the credit cart expiration year.

    $order->ccyear(2010);
    print $order->ccyear;

=head2 ccvn

=over

=item Arguments: $cvvn

=back

Gets/sets the credit cart verification number.

    $order->cvvn(102);
    print $order->cvvn;

=head2 ccname

=over

=item Arguments: $name

=back

Gets/sets the credit cart holders name as it appears on the card.

    $order->ccname('CHRISTOPHER H. LACO');
    print $order->ccname;

=head2 ccissuenumber

=over

=item Arguments: $number

=back

Gets/sets the credit cart issue number.

    $order->ccissuenumber(16544);
    print $order->ccissuenumber;

=head2 ccstartdate

=over

=item Arguments: $startdate

=back

Gets/sets the credit cart start date.

    $order->ccstartdate('1/2/2009');
    print $order->ccstartdate;

=head2 ccenddate

=over

=item Arguments: $enddate

=back

Gets/sets the credit cart end date.

    $order->ccenddate('12/31/2011');
    print $order->ccenddate;

=head1 SEE ALSO

L<Mango::Order::Item>, L<Mango::Schema::Order>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
