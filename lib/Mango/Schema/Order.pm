# $Id: Order.pm 1713 2007-02-04 23:59:50Z claco $
package Mango::Schema::Order;
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
__PACKAGE__->table('orders');
__PACKAGE__->source_name('Orders');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'INT',
        is_auto_increment => 1,
        is_nullable       => 0,
        extras            => {unsigned => 1}
    },
    user_id => {
        data_type      => 'INT',
        is_nullable    => 0,
        is_foreign_key => 1,
        extras         => {unsigned => 1}
    },
    type => {
        data_type     => 'TINYINT',
        size          => 3,
        is_nullable   => 0,
        default_value => 0,
        extras        => {unsigned => 1}
    },
    number => {
        data_type     => 'VARCHAR',
        size          => 20,
        is_nullable   => 1,
        default_value => undef
    },
    comments => {
        data_type     => 'VARCHAR',
        size          => 100,
        is_nullable   => 1,
        default_value => undef
    },
    shipmethod => {
        data_type     => 'VARCHAR',
        size          => 20,
        is_nullable   => 1,
        default_value => undef
    },
    shipping => {
        data_type      => 'DECIMAL',
        size           => [9,2],
        is_nullable    => 0,
        default_value  => '0.00'
    },
    handling => {
        data_type      => 'DECIMAL',
        size           => [9,2],
        is_nullable    => 0,
        default_value  => '0.00'
    },
    tax => {
        data_type      => 'DECIMAL',
        size           => [9,2],
        is_nullable    => 0,
        default_value  => '0.00'
    },
    subtotal => {
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
    billtofirstname => {
        data_type     => 'VARCHAR',
        size          => 25,
        is_nullable   => 1,
        default_value => undef
    },
    billtolastname => {
        data_type     => 'VARCHAR',
        size          => 25,
        is_nullable   => 1,
        default_value => undef
    },
    billtoaddress1 => {
        data_type     => 'VARCHAR',
        size          => 50,
        is_nullable   => 1,
        default_value => undef
    },
    billtoaddress2 => {
        data_type     => 'VARCHAR',
        size          => 50,
        is_nullable   => 1,
        default_value => undef
    },
    billtoaddress3 => {
        data_type     => 'VARCHAR',
        size          => 50,
        is_nullable   => 1,
        default_value => undef
    },
    billtocity => {
        data_type     => 'VARCHAR',
        size          => 50,
        is_nullable   => 1,
        default_value => undef
    },
    billtostate => {
        data_type     => 'VARCHAR',
        size          => 50,
        is_nullable   => 1,
        default_value => undef
    },
    billtozip => {
        data_type     => 'VARCHAR',
        size          => 10,
        is_nullable   => 1,
        default_value => undef
    },
    billtocountry => {
        data_type     => 'VARCHAR',
        size          => 25,
        is_nullable   => 1,
        default_value => undef
    },
    billtodayphone => {
        data_type     => 'VARCHAR',
        size          => 25,
        is_nullable   => 1,
        default_value => undef
    },
    billtonightphone => {
        data_type     => 'VARCHAR',
        size          => 25,
        is_nullable   => 1,
        default_value => undef
    },
    billtofax => {
        data_type     => 'VARCHAR',
        size          => 25,
        is_nullable   => 1,
        default_value => undef
    },
    billtoemail => {
        data_type     => 'VARCHAR',
        size          => 50,
        is_nullable   => 1,
        default_value => undef
    },
    shiptosameasbillto => {
        data_type     => 'VARCHAR',
        size          => 3,
        is_nullable   => 0,
        default_value => 1
    },
    shiptofirstname => {
        data_type     => 'VARCHAR',
        size          => 25,
        is_nullable   => 1,
        default_value => undef
    },
    shiptolastname => {
        data_type     => 'VARCHAR',
        size          => 25,
        is_nullable   => 1,
        default_value => undef
    },
    shiptoaddress1 => {
        data_type     => 'VARCHAR',
        size          => 50,
        is_nullable   => 1,
        default_value => undef
    },
    shiptoaddress2 => {
        data_type     => 'VARCHAR',
        size          => 50,
        is_nullable   => 1,
        default_value => undef
    },
    shiptoaddress3 => {
        data_type     => 'VARCHAR',
        size          => 50,
        is_nullable   => 1,
        default_value => undef
    },
    shiptocity => {
        data_type     => 'VARCHAR',
        size          => 50,
        is_nullable   => 1,
        default_value => undef
    },
    shiptostate => {
        data_type     => 'VARCHAR',
        size          => 50,
        is_nullable   => 1,
        default_value => undef
    },
    shiptozip => {
        data_type     => 'VARCHAR',
        size          => 10,
        is_nullable   => 1,
        default_value => undef
    },
    shiptocountry => {
        data_type     => 'VARCHAR',
        size          => 25,
        is_nullable   => 1,
        default_value => undef
    },
    shiptodayphone => {
        data_type     => 'VARCHAR',
        size          => 25,
        is_nullable   => 1,
        default_value => undef
    },
    shiptonightphone => {
        data_type     => 'VARCHAR',
        size          => 25,
        is_nullable   => 1,
        default_value => undef
    },
    shiptofax => {
        data_type     => 'VARCHAR',
        size          => 25,
        is_nullable   => 1,
        default_value => undef
    },
    shiptoemail => {
        data_type     => 'VARCHAR',
        size          => 50,
        is_nullable   => 1,
        default_value => undef
    },
    created => {
        data_type     => 'DATETIME',
        is_nullable   => 1,
        default_value => undef
    },
    updated => {
        data_type     => 'DATETIME',
        is_nullable   => 1,
        default_value => undef
    },
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many(items => 'Mango::Schema::Order::Item', {'foreign.order_id' => 'self.id'});
__PACKAGE__->default_values({
    created => sub {DateTime->now},
    updated => sub {DateTime->now}
});

1;
__END__
