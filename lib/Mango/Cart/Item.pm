package Mango::Cart::Item;
use strict;
use warnings;

BEGIN {
    use base qw/Handel::Cart::Item/;
    use Handel::Constraints ();
    use DateTime;
};
__PACKAGE__->storage->setup({
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
        created      => sub {DateTime->now}
    }
});
__PACKAGE__->result_iterator_class('Mango::Iterator');
__PACKAGE__->create_accessors;

=head1 NAME

Mango::Cart::Item - Cart Item Class

=head1 SYNOPSIS

    use Mango::Cart::Item;
    
    my $items = $cart->items;
    while (my $item = $items->next) {
        print $item->sku;
    };

=head1 DESCRIPTION

My Cart Item Class

=head1 AUTHOR

    Author <author@example.com>

=cut

1;
