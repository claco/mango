# $Id$
package Mango::Schema::User;
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
__PACKAGE__->table('user');
__PACKAGE__->source_name('Users');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'INT',
        is_auto_increment => 1,
        is_nullable       => 0,
        extras            => { unsigned => 1 }
    },
    username => {
        data_type   => 'VARCHAR',
        size        => 25,
        is_nullable => 0
    },
    password => {
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
__PACKAGE__->add_unique_constraint( username => [qw/username/] );
__PACKAGE__->has_many(
    map_user_role => 'Mango::Schema::UserRole',
    { 'foreign.user_id' => 'self.id' }
);
__PACKAGE__->many_to_many( roles => 'map_user_role', 'role' );
__PACKAGE__->might_have(
    profile => 'Mango::Schema::Profile',
    { 'foreign.user_id' => 'self.id' }
);
__PACKAGE__->has_many(
    wishlists => 'Mango::Schema::Wishlist',
    { 'foreign.user_id' => 'self.id' }
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

Mango::Schema::User - DBIC schema class for Users

=head1 SYNOPSIS

    use Mango::Schema;
    my $schema = Mango::Schema->connect;
    my $users = $schema->resultset('Users')->search;

=head1 DESCRIPTION

Mango::Schema::User is loaded by Mango::Schema to read/write user data.

=head1 COLUMNS

=head2 id

Contains the primary key for each role record.

    id => {
        data_type         => 'INT',
        is_auto_increment => 1,
        is_nullable       => 0,
        extras            => {unsigned => 1}
    },

=head2 username

Contains the user name.

    username => {
        data_type   => 'VARCHAR',
        size        => 25,
        is_nullable => 0
    },

=head2 password

The users password.

    password => {
        data_type   => 'VARCHAR',
        size        => 255,
        is_nullable => 0
    },

=head2 created

When the user record was created.

    created => {
        data_type   => 'DATETIME',
        is_nullable => 0
    },

=head2 updated

When the user record was updated.

    updated => {
        data_type   => 'DATETIME',
        is_nullable => 0
    }

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
