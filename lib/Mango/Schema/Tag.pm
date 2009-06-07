# $Id$
package Mango::Schema::Tag;
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
__PACKAGE__->table('tag');
__PACKAGE__->source_name('Tags');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'INT',
        is_auto_increment => 1,
        is_nullable       => 0,
        extras            => { unsigned => 1 }
    },
    name => {
        data_type   => 'VARCHAR',
        size        => 25,
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
__PACKAGE__->add_unique_constraint( tag_name => [qw/name/] );
__PACKAGE__->has_many(
    map_product_tag => 'Mango::Schema::ProductTag',
    { 'foreign.tag_id' => 'self.id' }
);
__PACKAGE__->many_to_many( products => 'map_product_tag', 'product' );
__PACKAGE__->default_values(
    {
        created => sub { DateTime->now },
        updated => sub { DateTime->now }
    }
);

1;
__END__

=head1 NAME

Mango::Schema::Tag - DBIC schema class for Tags

=head1 SYNOPSIS

    use Mango::Schema;
    my $schema = Mango::Schema->connect;
    my $tags = $schema->resultset('Tags')->search;

=head1 DESCRIPTION

Mango::Schema::Tag is loaded by Mango::Schema to read/write tag data.

=head1 COLUMNS

=head2 id

Contains the primary key for each tag record.

    id => {
        data_type         => 'INT',
        is_auto_increment => 1,
        is_nullable       => 0,
        extras            => {unsigned => 1}
    },

=head2 name

Contains the tag name.

    name => {
        data_type   => 'VARCHAR',
        size        => 25,
        is_nullable => 0
    },

=head2 created

When the role record was created.

    created => {
        data_type   => 'DATETIME',
        is_nullable => 0
    },

=head2 updated

When the role record was updated.

    updated => {
        data_type   => 'DATETIME',
        is_nullable => 0
    }

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
