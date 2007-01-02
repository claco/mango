package Mango::Schema::Users;
use strict;
use warnings;

BEGIN {
    use base qw/DBIx::Class/;
};

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('users');
__PACKAGE__->source_name('Users');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'UINT',
        is_auto_increment => 1,
        is_nullable       => 0
    },
    username => {
        data_type   => 'VARCHAR',
        size        => '25',
        is_nullable => 0
    },
    password => {
        data_type   => 'VARCHAR',
        size        => '255',
        is_nullable => 0
    }
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(
    name => [qw/username/]
);

__PACKAGE__->has_many(
    map_users_roles => 'Mango::Schema::UsersRoles',
    {'foreign.user_id' => 'self.id'}
);
__PACKAGE__->many_to_many(roles => 'map_users_roles', 'role');

1;
__END__

=head1 NAME

Mango::Schema::Users - DBIC schema class for Users

=head1 SYNOPSIS

    use Mango::Schema;
    my $schema = Mango::Schema->connect;
    my $roles = $schema->resultset('Users')->search;

=head1 DESCRIPTION

Mango::Schema::Users is loaded by Mango::Schema to read/write user data.

=head1 COLUMNS

=head2 id

Contains the primary key for each role record.

    id => {
        data_type         => 'UINT',
        is_auto_increment => 1,
        is_nullable       => 0
    },

=head2 username

Contains the user name.

    username => {
        data_type   => 'VARCHAR',
        size        => '25',
        is_nullable => 0
    },

=head2 password

The users password.

    password => {
        data_type   => 'VARCHAR',
        size        => '255',
        is_nullable => 0
    }

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
