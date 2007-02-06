# $Id$
package Mango::Schema::Product;
use strict;
use warnings;

BEGIN {
    use base qw/DBIx::Class/;
    use Mango::Currency ();
    use DateTime ();
};

__PACKAGE__->load_components(qw/
    +Handel::Components::DefaultValues
    +Handel::Components::Constraints
    +Handel::Components::Validation
    InflateColumn::DateTime
    Core
/);
__PACKAGE__->table('product');
__PACKAGE__->source_name('Products');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'INT',
        is_auto_increment => 1,
        is_nullable       => 0,
        extras            => {unsigned => 1}
    },
    sku => {
        data_type      => 'VARCHAR',
        size           => 25,
        is_nullable    => 0,
    },
    name => {
        data_type   => 'VARCHAR',
        size        => 25,
        is_nullable => 0
    },
    description => {
        data_type   => 'VARCHAR',
        size        => 100,
        is_nullable => 1
    },
    price => {
        data_type      => 'DECIMAL',
        size           => [9,2],
        is_nullable    => 0,
        default_value  => '0.00'
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
__PACKAGE__->add_unique_constraint(
    sku => [qw/sku/]
);
__PACKAGE__->has_many(attributes => 'Mango::Schema::ProductAttributes', {'foreign.product_id' => 'self.id'});
__PACKAGE__->default_values({
    created => sub {DateTime->now},
    updated => sub {DateTime->now}
});
__PACKAGE__->inflate_column('price', {
    inflate => sub {Mango::Currency->new(shift);},
    deflate => sub {shift->value;}
});

1;
__END__

=head1 NAME

Mango::Schema::Role - DBIC schema class for Roles

=head1 SYNOPSIS

    use Mango::Schema;
    my $schema = Mango::Schema->connect;
    my $roles = $schema->resultset('Roles')->search;

=head1 DESCRIPTION

Mango::Schema::Roles is loaded by Mango::Schema to read/write role data.

=head1 COLUMNS

=head2 id

Contains the primary key for each role record.

    id => {
        data_type         => 'UINT',
        is_auto_increment => 1,
        is_nullable       => 0
    },

=head2 name

Contains the role name.

    name => {
        data_type   => 'VARCHAR',
        size        => '25',
        is_nullable => 0
    }

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
