# $Id$
package Mango::Schema::Profiles;
use strict;
use warnings;

BEGIN {
    use base qw/DBIx::Class/;
};

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('profiles');
__PACKAGE__->source_name('Profiles');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'UINT',
        is_auto_increment => 1,
        is_nullable       => 0
    },
    user_id => {
        data_type   => 'UINT',
        is_nullable => 0
    },
    first_name => {
        data_type   => 'VARCHAR',
        size        => 25,
        is_nullable => 1
    },
    last_name => {
        data_type   => 'VARCHAR',
        size        => 25,
        is_nullable => 1
    },
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(
    user_id => [qw/user_id/]
);
__PACKAGE__->belongs_to(user => 'Mango::Schema::Users',
    {'foreign.id' => 'self.user_id'}
);
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
