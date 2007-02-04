# $Id$
package Mango::Schema::Profile;
use strict;
use warnings;

BEGIN {
    use base qw/DBIx::Class/;
    use DateTime ();
};

__PACKAGE__->load_components(qw/
    +Handel::Components::DefaultValues
    +Handel::Components::Constraints
    +Handel::Components::Validation
    InflateColumn::DateTime
    Core
/);
__PACKAGE__->table('profile');
__PACKAGE__->source_name('Profiles');
__PACKAGE__->add_columns(
    id => {
        data_type         => 'INT',
        is_auto_increment => 1,
        is_nullable       => 0,
        extras            => {unsigned => 1}
    },
    user_id => {
        data_type      => 'INT',
        is_nullable    => 0,
        is_foreign_key => 1,
        extras         => {unsigned => 1}
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
    user_id => [qw/user_id/]
);
__PACKAGE__->belongs_to(user => 'Mango::Schema::User',
    {'foreign.id' => 'self.user_id'}
);
__PACKAGE__->default_values({
    created => sub {DateTime->now},
    updated => sub {DateTime->now}
});

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
