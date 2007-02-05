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

=head1 NAME

Mango::Order - Order Class

=head1 SYNOPSIS

    use Mango::Order;
    
    my $order = Mango::Order->create({
        id   => $id
    });

=head1 DESCRIPTION

My Order Class

=head1 AUTHOR

    Author <author@example.com>

=cut

1;
