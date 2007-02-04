# $Id$
package Mango::Schema::Cart::Item;
use strict;
use warnings;

BEGIN {
    use base qw/DBIx::Class/;
};

__PACKAGE__->load_components(qw/
    +Handel::Components::DefaultValues
    +Handel::Components::Constraints
    +Handel::Components::Validation
    InflateColumn::DateTime
    Core
/);
__PACKAGE__->table('cart_item');
__PACKAGE__->source_name('CartItems');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'INT',
        is_auto_increment => 1,
        is_nullable       => 0,
        extras            => {unsigned => 1}
    },
    cart_id => {
        data_type         => 'INT',
        is_nullable       => 0,
        is_foreign_key    => 1,
        extras            => {unsigned => 1}
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
        default_value  => 1,
        extras         => {unsigned => 1}
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
    },
    created => {
        data_type     => 'DATETIME',
        is_nullable   => 0
    },
    updated => {
        data_type     => 'DATETIME',
        is_nullable   => 0
    }
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(cart => 'Mango::Schema::Cart',
    {'foreign.id' => 'self.cart_id'}
);
__PACKAGE__->default_values({
    created => sub {DateTime->now},
    updated => sub {DateTime->now}
});

1;
__END__
