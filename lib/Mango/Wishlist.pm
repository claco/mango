# $Id$
package Mango::Wishlist;
use strict;
use warnings;

BEGIN {
    use base qw/Handel::Cart/;
    use Handel::Constraints ();
    use DateTime ();
};

## Yes, this isn't the preferred way. Sue me. I don't want the storage classes
## floating around this dist. If you make your own cart, feel free to do it the
## correct way. ;-)
__PACKAGE__->item_class('Mango::Wishlist::Item');
__PACKAGE__->storage->setup({
    schema_class       => 'Mango::Schema',
    schema_source      => 'Wishlists',
    constraints        => {
        name           => {'Check Name'    => \&Handel::Constraints::constraint_cart_name},
    },
    default_values     => {
        created        => sub {DateTime->now}
    },
    validation_profile => undef
});
__PACKAGE__->create_accessors;

sub search {
    my $class = shift;

    return $class->SUPER::search(@_);
};

sub save {
    
};

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
