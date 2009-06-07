# $Id$
package Mango::Schema::ProductAttribute;
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
__PACKAGE__->table('product_attribute');
__PACKAGE__->source_name('ProductAttributes');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'INT',
        is_auto_increment => 1,
        is_nullable       => 0,
        extras            => { unsigned => 1 }
    },
    product_id => {
        data_type      => 'INT',
        is_nullable    => 0,
        is_foreign_key => 1,
        extras         => { unsigned => 1 }
    },
    name => {
        data_type   => 'VARCHAR',
        size        => 25,
        is_nullable => 0
    },
    value => {
        data_type   => 'VARCHAR',
        size        => 255,
        is_nullable => 0
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
__PACKAGE__->add_unique_constraint(
    product_attribute_name => [qw/product_id name/] );
__PACKAGE__->belongs_to(
    product => 'Mango::Schema::Product',
    { 'foreign.id' => 'self.product_id' }
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

Mango::Schema::ProductAttribute - DBIC schema class for product attributes

=head1 SYNOPSIS

    use Mango::Schema;
    my $schema = Mango::Schema->connect;
    my $attributes = $schema->resultset('ProductAttributes')->search;

=head1 DESCRIPTION

Mango::Schema::ProductAttribute is loaded by Mango::Schema to read/write product attribute data.

=head1 COLUMNS

=head2 id

Contains the primary key for each attribute record.

    id => {
        data_type         => 'INT',
        is_auto_increment => 1,
        is_nullable       => 0,
        extras            => {unsigned => 1}
    },

=head2 product_id

The product id foreign key assigned to the attribute.

    product_id => {
        data_type      => 'INT',
        is_nullable    => 0,
        is_foreign_key => 1,
        extras         => {unsigned => 1}
    },

=head2 name

Contains the attribute name.

    name => {
        data_type   => 'VARCHAR',
        size        => 25,
        is_nullable => 0
    },

=head2 value

The value of the attribute.

    value => {
        data_type   => 'VARCHAR',
        size        => 255,
        is_nullable => 0
    },

=head2 created

When the attribute record was created.

    created => {
        data_type   => 'DATETIME',
        is_nullable => 0
    },

=head2 updated

When the attribute record was updated.

    updated => {
        data_type   => 'DATETIME',
        is_nullable => 0
    }

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
