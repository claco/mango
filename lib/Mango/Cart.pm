package Mango::Cart;
use strict;
use warnings;

BEGIN {
    use base qw/Handel::Cart/;
};

__PACKAGE__->storage_class('Mango::Storage::Cart');
__PACKAGE__->item_class('Mango::Cart::Item');
__PACKAGE__->create_accessors;

=head1 NAME

Mango::Cart - Cart Class

=head1 SYNOPSIS

    use Mango::Cart;
    
    my $cart = Mango::Cart->create({
        id   => $id,
        name => 'MyCart'
    });

=head1 DESCRIPTION

My Cart Class

=head1 AUTHOR

    Author <author@example.com>

=cut

1;
