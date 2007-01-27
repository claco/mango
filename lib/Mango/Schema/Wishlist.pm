# $Id$
package Mango::Schema::Wishlist;
use strict;
use warnings;

BEGIN {
    use base qw/DBIx::Class/;
    use DateTime ();
};

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);
__PACKAGE__->table('wishlist');
__PACKAGE__->source_name('Wishlists');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'UINT',
        is_auto_increment => 1,
        is_nullable       => 0
    },
    user_id => {
        data_type      => 'UINT',
        is_nullable    => 0,
        is_foreign_key => 1
    },
    name => {
        data_type     => 'VARCHAR',
        size          => 50,
        is_nullable   => 0
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
    }
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many(items => 'Mango::Schema::Wishlist::Item', {'foreign.wishlist_id' => 'self.id'});
__PACKAGE__->belongs_to(user => 'Mango::Schema::User',
    {'foreign.id' => 'self.user_id'}
);

1;
__END__
