# $Id$
package Mango::Schema::Cart;
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
__PACKAGE__->table('cart');
__PACKAGE__->source_name('Carts');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'INT',
        is_auto_increment => 1,
        is_nullable       => 0,
        extras            => { unsigned => 1 }
    },
    user_id => {
        data_type      => 'INT',
        is_nullable    => 1,
        is_foreign_key => 1,
        extras         => { unsigned => 1 }
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
    items => 'Mango::Schema::Cart::Item',
    { 'foreign.cart_id' => 'self.id' }
);
__PACKAGE__->might_have(
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

Mango::Schema::Cart - DBIC schema class for carts

=head1 SYNOPSIS

    use Mango::Schema;
    my $schema = Mango::Schema->connect;
    my $carts = $schema->resultset('Carts')->search;

=head1 DESCRIPTION

Mango::Schema::Cart is loaded by Mango::Schema to read/write cart data.

=head1 COLUMNS

=head2 id

Contains the primary key for each cart record.

    id => {
        data_type         => 'INT',
        is_auto_increment => 1,
        is_nullable       => 0,
        extras            => {unsigned => 1}
    },

=head2 user_id

Contains the foreign key to the user this cart belongs to.

    user_id => {
        data_type      => 'INT',
        is_nullable    => 1,
        is_foreign_key => 1,
        extras         => {unsigned => 1}
    },

=head2 created

When the cart record was created.

    created => {
        data_type   => 'DATETIME',
        is_nullable => 0
    },

=head2 updated

When the cart record was updated.

    updated => {
        data_type   => 'DATETIME',
        is_nullable => 0
    }

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
