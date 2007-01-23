package Mango::Storage::Cart::Item;
use strict;
use warnings;

BEGIN {
    use base qw/Handel::Storage::DBIC/;
    use Handel::Constraints qw/:all/;
};

__PACKAGE__->setup({
    schema_class     => 'Mango::Schema',
    schema_source    => 'CartItems',
    currency_columns => [qw/price/],
    constraints      => {
        quantity     => {'Check Quantity' => \&constraint_quantity},
        price        => {'Check Price'    => \&constraint_price}
    },
    default_values   => {
        price        => 0,
        quantity     => 1
    }
});

=head1 NAME

Mango::Storage::Cart::Item - Cart Item Storage Class

=head1 SYNOPSIS

    __PACKAGE__->storage_class('Mango::Storage::Cart::Item');

=head1 DESCRIPTION

My Cart Item Storage Class

=head1 AUTHOR

    Author <author@example.com>

=cut

1;
