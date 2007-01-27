# $Id$
package Mango::Wishlist::Item;
use strict;
use warnings;

BEGIN {
    use base qw/Handel::Cart::Item/;
    use Handel::Constraints ();
    use DateTime;
};
__PACKAGE__->storage->setup({
    schema_class     => 'Mango::Schema',
    schema_source    => 'WishlistItems',
    constraints      => {
        quantity     => {'Check Quantity' => \&Handel::Constraints::constraint_quantity}
    },
    default_values   => {
        quantity     => 1,
        created      => sub {DateTime->now}
    }
});
__PACKAGE__->create_accessors;

=head1 NAME

Mango::Wishlist::Item - Wishlist Item Class

=head1 SYNOPSIS

    use Mango::Wishlist::Item;
    
    my $items = $cart->items;
    while (my $item = $items->next) {
        print $item->sku;
    };

=head1 DESCRIPTION

My WishlistItem Class

=head1 AUTHOR

    Author <author@example.com>

=cut

1;
