# $Id: Cart.pm 1713 2007-02-04 23:59:50Z claco $
package Mango::Schema::Cart;
use strict;
use warnings;

BEGIN {
    use base qw/DBIx::Class/;
    use DateTime ();
};

__PACKAGE__->load_components(qw/
    +Handel::Components::DefaultValues
    +Handel::Components::Constraints
    +Handel::Components::Validation
    InflateColumn::DateTime
    Core
/);
__PACKAGE__->table('cart');
__PACKAGE__->source_name('Carts');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'INT',
        is_auto_increment => 1,
        is_nullable       => 0,
        extras            => {unsigned => 1}
    },
    user_id => {
        data_type      => 'INT',
        is_nullable    => 1,
        is_foreign_key => 1,
        default_value  => undef,
        extras         => {unsigned => 1}
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
__PACKAGE__->has_many(items => 'Mango::Schema::Cart::Item', {'foreign.cart_id' => 'self.id'});
__PACKAGE__->might_have(user => 'Mango::Schema::User',
    {'foreign.id' => 'self.user_id'}
);
__PACKAGE__->default_values({
    created => sub {DateTime->now},
    updated => sub {DateTime->now}
});

1;
__END__
