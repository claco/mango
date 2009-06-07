# $Id$
package Mango::Schema::Wishlist::Item;
use strict;
use warnings;

BEGIN {
    use base qw/DBIx::Class/;
    use DateTime ();
}

__PACKAGE__->load_components(
    qw/
      +Handel::Components::DefaultValues
      +Handel::Components::Constraints
      +Handel::Components::Validation
      InflateColumn::DateTime
      Core
      /
);
__PACKAGE__->table('wishlist_item');
__PACKAGE__->source_name('WishlistItems');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'INT',
        is_auto_increment => 1,
        is_nullable       => 0,
        extras            => { unsigned => 1 }
    },
    wishlist_id => {
        data_type         => 'INT',
        is_auto_increment => 1,
        is_nullable       => 0,
        is_foreign_key    => 1,
        extras            => { unsigned => 1 }
    },
    sku => {
        data_type   => 'VARCHAR',
        size        => 25,
        is_nullable => 0,
    },
    quantity => {
        data_type     => 'TINYINT',
        size          => 3,
        is_nullable   => 0,
        default_value => 1,
        extras        => { unsigned => 1 }
    },
    description => {
        data_type     => 'VARCHAR',
        size          => 255,
        is_nullable   => 1,
        default_value => undef
    },
    created => {
        data_type   => 'DATETIME',
        is_nullable => 0,
        timezone => 'UTC'
    },
    updated => {
        data_type   => 'DATETIME',
        is_nullable => 0,
        timezone => 'UTC'
    }
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(
    wishlist => 'Mango::Schema::Wishlist',
    { 'foreign.id' => 'self.wishlist_id' }
);
__PACKAGE__->might_have(
    product => 'Mango::Schema::Product',
    { 'foreign.sku'    => 'self.sku' },
    { 'cascade_delete' => 0 }
);
__PACKAGE__->default_values(
    {
        created => sub { DateTime->now },
        updated => sub { DateTime->now }
    }
);

1;
__END__

=head1 NAME

Mango::Schema::Wishlist::Item - DBIC schema class for wishlist items

=head1 SYNOPSIS

    use Mango::Schema;
    my $schema = Mango::Schema->connect;
    my $items = $schema->resultset('WishlistItems')->search;

=head1 DESCRIPTION

Mango::Schema::Wishlist::Item is loaded by Mango::Schema to read/write
wishlist item data.

=head1 COLUMNS

=head2 id

Contains the primary key for each wishlist item record.

    id => {
        data_type         => 'INT',
        is_auto_increment => 1,
        is_nullable       => 0,
        extras            => {unsigned => 1}
    },

=head2 wishlist_id

Contains the foreign key to the wishlist table.

    wishlist_id => {
        data_type         => 'INT',
        is_nullable       => 0,
        is_foreign_key    => 1,
        extras            => {unsigned => 1}
    },

=head2 sku

Contains the sku (Stock Keeping Unit), or part number for the current
wishlist item.

    sku => {
        data_type      => 'VARCHAR',
        size           => 25,
        is_nullable    => 0,
    },

=head2 quantity

Contains the number of this wishlist item being ordered.

    quantity => {
        data_type      => 'TINYINT',
        size           => 3,
        is_nullable    => 0,
        default_value  => 1,
        extras         => {unsigned => 1}
    },

=head2 description

Contains the description of the current wishlist item.

    description => {
        data_type     => 'VARCHAR',
        size          => 255,
        is_nullable   => 1,
        default_value => undef
    },

=head2 created

When the wishlist item record was created.

    created => {
        data_type   => 'DATETIME',
        is_nullable => 0
    },

=head2 updated

When the wishlist item record was updated.

    updated => {
        data_type   => 'DATETIME',
        is_nullable => 0
    }

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
