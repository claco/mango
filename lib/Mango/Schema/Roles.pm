# $Id$
package Mango::Schema::Roles;
use strict;
use warnings;

BEGIN {
    use base qw/DBIx::Class/;
};

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('roles');
__PACKAGE__->source_name('Roles');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'UINT',
        is_auto_increment => 1,
        is_nullable       => 0
    },
    name => {
        data_type   => 'VARCHAR',
        size        => '25',
        is_nullable => 0
    }
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(
    name => [qw/name/]
);

__PACKAGE__->has_many(
    map_users_roles => 'Mango::Schema::UsersRoles',
    {'foreign.role_id' => 'self.id'}
);
__PACKAGE__->many_to_many(users => 'map_users_roles', 'user');

1;
__END__

=head1 NAME

Mango::Schema::Roles - DBIC schema class for Roles

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
