# $Id$
package Mango::Schema::Cart;
use strict;
use warnings;

BEGIN {
    use base qw/DBIx::Class/;
};

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('carts');
__PACKAGE__->source_name('Carts');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'UINT',
        is_auto_increment => 1,
        is_nullable       => 0
    },
    user_id => {
        data_type      => 'UINT',
        is_nullable    => 0,
        default_value  => 0,
        is_foreign_key => 1
    },
    type => {
        data_type     => 'TINYINT',
        size          => 3,
        is_nullable   => 0,
        default_value => 0
    },
    name => {
        data_type     => 'VARCHAR',
        size          => 50,
        is_nullable   => 1,
        default_value => undef
    },
    description => {
        data_type     => 'VARCHAR',
        size          => 255,
        is_nullable   => 1,
        default_value => undef
    }
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many(items => 'Mango::Schema::Cart::Item', {'foreign.cart_id' => 'self.id'});
__PACKAGE__->might_have(user => 'Mango::Schema::Users',
    {'foreign.id' => 'self.user_id'}
);

1;
__END__
