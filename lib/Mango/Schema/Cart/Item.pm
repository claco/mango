# $Id$
package Mango::Schema::Cart::Item;
use strict;
use warnings;

BEGIN {
    use base qw/DBIx::Class/;
};

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('carts_items');
__PACKAGE__->source_name('CartItems');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'UINT',
        is_auto_increment => 1,
        is_nullable       => 0
    },
    cart_id => {
        data_type      => 'UINT',
        is_nullable    => 0,
        is_foreign_key => 1
    },
    sku => {
        data_type      => 'VARCHAR',
        size           => 25,
        is_nullable    => 0,
    },
    quantity => {
        data_type      => 'TINYINT',
        size           => 3,
        is_nullable    => 0,
        default_value  => 1
    },
    price => {
        data_type      => 'DECIMAL',
        size           => [9,2],
        is_nullable    => 0,
        default_value  => '0.00'
    },
    description => {
        data_type     => 'VARCHAR',
        size          => 255,
        is_nullable   => 1,
        default_value => undef
    }
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(cart => 'Mango::Schema::Cart',
    {'foreign.id' => 'self.cart_id'}
);

1;
__END__
