# $Id$
package Mango::Schema::Role;
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
__PACKAGE__->table('role');
__PACKAGE__->source_name('Roles');
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
    description => {
        data_type   => 'VARCHAR',
        size        => 100,
        is_nullable => 1
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
__PACKAGE__->add_unique_constraint( name => [qw/name/] );
__PACKAGE__->has_many(
    map_user_role => 'Mango::Schema::UserRole',
    { 'foreign.role_id' => 'self.id' }
);
__PACKAGE__->many_to_many( users => 'map_user_role', 'user' );
__PACKAGE__->default_values(
    {
        created => sub { DateTime->now },
        updated => sub { DateTime->now }
    }
);

1;
__END__

=head1 NAME

Mango::Schema::Role - DBIC schema class for Roles

=head1 SYNOPSIS

    use Mango::Schema;
    my $schema = Mango::Schema->connect;
    my $roles = $schema->resultset('Roles')->search;

=head1 DESCRIPTION

Mango::Schema::Role is loaded by Mango::Schema to read/write role data.

=head1 COLUMNS

=head2 id

Contains the primary key for each role record.

    id => {
        data_type         => 'INT',
        is_auto_increment => 1,
        is_nullable       => 0,
        extras            => {unsigned => 1}
    },

=head2 name

Contains the role name.

    name => {
        data_type   => 'VARCHAR',
        size        => 25,
        is_nullable => 0
    },

=head2 description

The description of the role.

    description => {
        data_type   => 'VARCHAR',
        size        => 100,
        is_nullable => 1
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
