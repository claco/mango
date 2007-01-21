# $Id$
package Mango::Schema::UsersRoles;
use strict;
use warnings;

BEGIN {
    use base qw/DBIx::Class/;
};

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('users_roles');
__PACKAGE__->source_name('UsersRoles');
__PACKAGE__->add_columns(
    user_id => {
        data_type   => 'UINT',
        is_nullable => 0
    },
    role_id => {
        data_type   => 'UINT',
        is_nullable => 0
    },
);
__PACKAGE__->set_primary_key(qw/user_id role_id/);
__PACKAGE__->belongs_to(
    user => 'Mango::Schema::Users',
    {'foreign.id' => 'self.user_id'}
);
__PACKAGE__->belongs_to(
    role => 'Mango::Schema::Roles',
    {'foreign.id' => 'self.role_id'}
);

1;
__END__

=head1 NAME

Mango::Schema::UsersRoles - DBIC schema class for Users Role membership

=head1 SYNOPSIS

    use Mango::Schema;
    my $schema = Mango::Schema->connect;
    my $roles = $schema->resultset('UUsersRoles')->search;

=head1 DESCRIPTION

Mango::Schema::UsersRoles is loaded by Mango::Schema to read/write role
membership data.

=head1 COLUMNS

=head2 user_id

Contains the user id for each role record.

    user_id => {
        data_type   => 'UINT',
        is_nullable => 0
    },

=head2 role_id

Contains the role id for each role record.

    user_id => {
        data_type   => 'UINT',
        is_nullable => 0
    }

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/