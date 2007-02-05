# $Id$
package Mango::Cart::Item;
use strict;
use warnings;

BEGIN {
    use base qw/Handel::Cart::Item/;
    use Handel::Constraints ();
    use DateTime ();
    use XML::Feed::Entry ();
};
__PACKAGE__->storage->setup({
    autoupdate       => 0,
    currency_class   => 'Mango::Currency',
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
        created      => sub {DateTime->now},
        updated      => sub {DateTime->now}
    }
});
__PACKAGE__->result_iterator_class('Mango::Iterator');
__PACKAGE__->create_accessors;

sub update {
    my $self = shift;

    $self->updated(DateTime->now);
  
    return $self->SUPER::update(@_);
};

sub as_entry {
    my ($self, $format) = @_;
    my $entry  = XML::Feed::Entry->new($format);

    $entry->id($self->id);
    $entry->title($self->sku);
    #$entry->content($self->description);
    $entry->summary($self->description);
    $entry->category('cart');
    $entry->issued($self->created);
    $entry->modified($self->updated);

    return $entry;
};

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
