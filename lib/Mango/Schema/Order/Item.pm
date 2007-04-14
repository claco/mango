# $Id$
package Mango::Schema::Order::Item;
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
__PACKAGE__->table('order_item');
__PACKAGE__->source_name('OrderItems');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'INT',
        is_auto_increment => 1,
        is_nullable       => 0,
        extras            => {unsigned => 1}
    },
    order_id => {
        data_type      => 'INT',
        is_nullable    => 0,
        is_foreign_key => 1,
        extras         => {unsigned => 1}
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
    total => {
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
__PACKAGE__->belongs_to(order => 'Mango::Schema::Order',
    {'foreign.id' => 'self.order_id'}
);
__PACKAGE__->default_values({
    created => sub {DateTime->now},
    updated => sub {DateTime->now}
});

1;
__END__

=head1 NAME

Mango::Schema::Order::Item - DBIC schema class for order items

=head1 SYNOPSIS

    use Mango::Schema;
    my $schema = Mango::Schema->connect;
    my $items = $schema->resultset('OrderItems')->search;

=head1 DESCRIPTION

Mango::Schema::Order::Item is loaded by Mango::Schema to read/write order item data.

=head1 COLUMNS

=head2 id

Contains the primary key for each order item record.

    id => {
        data_type         => 'INT',
        is_auto_increment => 1,
        is_nullable       => 0,
        extras            => {unsigned => 1}
    },

=head2 order_id

Contains the foreign key to the orders table.

    order_id => {
        data_type         => 'INT',
        is_nullable       => 0,
        is_foreign_key    => 1,
        extras            => {unsigned => 1}
    },

=head2 sku

Contains the sku (Stock Keeping Unit), or part number for the current order item.

    sku => {
        data_type      => 'VARCHAR',
        size           => 25,
        is_nullable    => 0,
    },

=head2 quantity

Contains the number of this order item being ordered.

    quantity => {
        data_type      => 'TINYINT',
        size           => 3,
        is_nullable    => 0,
        default_value  => 1,
        extras         => {unsigned => 1}
    },

=head2 price

The price of the current order item.

    price => {
        data_type      => 'DECIMAL',
        size           => [9,2],
        is_nullable    => 0,
        default_value  => '0.00'
    },

=head2 total

The total cost of this order item.

    total => {
        data_type      => 'DECIMAL',
        size           => [9,2],
        is_nullable    => 0,
        default_value  => '0.00'
    },

=head2 description

Contains the description of the current order item.

    description => {
        data_type     => 'VARCHAR',
        size          => 255,
        is_nullable   => 1,
        default_value => undef
    },

=head2 created

When the order item record was created.

    created => {
        data_type   => 'DATETIME',
        is_nullable => 0
    },

=head2 updated

When the order item record was updated.

    updated => {
        data_type   => 'DATETIME',
        is_nullable => 0
    }

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
