package Mango::Storage::Cart;
use strict;
use warnings;

BEGIN {
    use base qw/Handel::Storage::DBIC/;
    use Handel::Constants qw/CART_TYPE_TEMP/;
    use Handel::Constraints qw/:all/;
};

__PACKAGE__->setup({
    schema_class       => 'Mango::Schema',
    schema_source      => 'Carts',
    item_storage_class => 'Mango::Storage::Cart::Item',
    constraints        => {
        type           => {'Check Type'    => \&constraint_cart_type},
        name           => {'Check Name'    => \&constraint_cart_name}
    },
    default_values     => {
        user_id        => 0,
        type           => CART_TYPE_TEMP
    }
});

=head1 NAME

Mango::Storage::Cart - Cart Storage Class

=head1 SYNOPSIS

    __PACKAGE__->storage_class('Mango::Storage::Cart');

=head1 DESCRIPTION

My Cart Storage Class

=head1 AUTHOR

    Author <author@example.com>

=cut

1;
