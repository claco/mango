# $Id$
package Mango::Schema::ProductTag;
use strict;
use warnings;

BEGIN {
    use base qw/DBIx::Class/;
};

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('product_tag');
__PACKAGE__->source_name('ProductTags');
__PACKAGE__->add_columns(
    product_id => {
        data_type      => 'INT',
        is_nullable    => 0,
        is_foreign_key => 1,
        extras         => {unsigned => 1}
    },
    tag_id => {
        data_type      => 'INT',
        is_nullable    => 0,
        is_foreign_key => 1,
        extras         => {unsigned => 1}
    },
);
__PACKAGE__->set_primary_key(qw/product_id tag_id/);
__PACKAGE__->belongs_to(
    product => 'Mango::Schema::Product',
    {'foreign.id' => 'self.product_id'}
);
__PACKAGE__->belongs_to(
    tag => 'Mango::Schema::Tag',
    {'foreign.id' => 'self.tag_id'}
);

1;
__END__

=head1 NAME

Mango::Schema::ProductTag - DBIC schema class for Product Tag membership

=head1 SYNOPSIS

    use Mango::Schema;
    my $schema = Mango::Schema->connect;
    my $roles = $schema->resultset('UsersRoles')->search;

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
