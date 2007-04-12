# $Id: UserRole.pm 1713 2007-02-04 23:59:50Z claco $
package Mango::Schema::UserRole;
use strict;
use warnings;

BEGIN {
    use base qw/DBIx::Class/;
};

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('user_role');
__PACKAGE__->source_name('UsersRoles');
__PACKAGE__->add_columns(
    user_id => {
        data_type      => 'INT',
        is_nullable    => 0,
        is_foreign_key => 1,
        extras         => {unsigned => 1}
    },
    role_id => {
        data_type      => 'INT',
        is_nullable    => 0,
        is_foreign_key => 1,
        extras         => {unsigned => 1}
    },
);
__PACKAGE__->set_primary_key(qw/user_id role_id/);
__PACKAGE__->belongs_to(
    user => 'Mango::Schema::User',
    {'foreign.id' => 'self.user_id'}
);
__PACKAGE__->belongs_to(
    role => 'Mango::Schema::Role',
    {'foreign.id' => 'self.role_id'}
);

1;
__END__

=head1 NAME

Mango::Schema::UserRole - DBIC schema class for users role membership

=head1 SYNOPSIS

    use Mango::Schema;
    my $schema = Mango::Schema->connect;
    my $user_roles = $schema->resultset('UsersRoles')->search;

=head1 DESCRIPTION

Mango::Schema::UsersRole is loaded by Mango::Schema to read/write user/role
membership data.

=head1 COLUMNS

=head2 user_id

Contains the user id for each role record.

    user_id => {
        data_type      => 'INT',
        is_nullable    => 0,
        is_foreign_key => 1,
        extras         => {unsigned => 1}
    },

=head2 role_id

Contains the role id for each role record.

    role_id => {
        data_type      => 'INT',
        is_nullable    => 0,
        is_foreign_key => 1,
        extras         => {unsigned => 1}
    }

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
