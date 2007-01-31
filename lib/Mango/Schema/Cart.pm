# $Id$
package Mango::Schema::Cart;
use strict;
use warnings;

BEGIN {
    use base qw/DBIx::Class/;
    use Handel::Constants qw/CART_TYPE_TEMP/;
    use DateTime ();
};

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);
__PACKAGE__->table('cart');
__PACKAGE__->source_name('Carts');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'UINT',
        is_auto_increment => 1,
        is_nullable       => 0
    },
    user_id => {
        data_type      => 'UINT',
        is_nullable    => 1,
        is_foreign_key => 1,
        default_value  => undef
    },
    created => {
        data_type     => 'DATETIME',
        is_nullable   => 0
    }
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many(items => 'Mango::Schema::Cart::Item', {'foreign.cart_id' => 'self.id'});
__PACKAGE__->might_have(user => 'Mango::Schema::User',
    {'foreign.id' => 'self.user_id'}
);

1;
__END__
