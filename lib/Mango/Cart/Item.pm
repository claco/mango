package Mango::Cart::Item;
use strict;
use warnings;

BEGIN {
    use base qw/Handel::Cart::Item/;
};

__PACKAGE__->storage_class('Mango::Storage::Cart::Item');
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
