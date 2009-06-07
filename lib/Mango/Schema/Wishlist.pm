# $Id$
package Mango::Schema::Wishlist;
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
__PACKAGE__->table('wishlist');
__PACKAGE__->source_name('Wishlists');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'INT',
        is_auto_increment => 1,
        is_nullable       => 0,
        extras            => { unsigned => 1 }
    },
    user_id => {
        data_type      => 'INT',
        is_nullable    => 0,
        is_foreign_key => 1,
        extras         => { unsigned => 1 }
    },
    name => {
        data_type   => 'VARCHAR',
        size        => 50,
        is_nullable => 0
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
__PACKAGE__->has_many(
    items => 'Mango::Schema::Wishlist::Item',
    { 'foreign.wishlist_id' => 'self.id' }
);
__PACKAGE__->belongs_to(
    user => 'Mango::Schema::User',
    { 'foreign.id' => 'self.user_id' }
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

Mango::Schema::Wishlist - DBIC schema class for wishlists

=head1 SYNOPSIS

    use Mango::Schema;
    my $schema = Mango::Schema->connect;
    my $carts = $schema->resultset('Wishlists')->search;

=head1 DESCRIPTION

Mango::Schema::Wishlist is loaded by Mango::Schema to read/write wishlist
data.

=head1 COLUMNS

=head2 id

Contains the primary key for each wishlist record.

    id => {
        data_type         => 'INT',
        is_auto_increment => 1,
        is_nullable       => 0,
        extras            => {unsigned => 1}
    },

=head2 user_id

Contains the foreign key to the user this wishlist belongs to.

    user_id => {
        data_type      => 'INT',
        is_nullable    => 1,
        is_foreign_key => 1,
        default_value  => undef,
        extras         => {unsigned => 1}
    },

=head2 name

The name of the wishlist.

    name => {
        data_type     => 'VARCHAR',
        size          => 50,
        is_nullable   => 0
    },

=head2 description

The description of the wishlist.

    description => {
        data_type     => 'VARCHAR',
        size          => 255,
        is_nullable   => 1,
        default_value => undef
    },

=head2 created

When the wishlist record was created.

    created => {
        data_type   => 'DATETIME',
        is_nullable => 0
    },

=head2 updated

When the wishlist record was updated.

    updated => {
        data_type   => 'DATETIME',
        is_nullable => 0
    }

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
