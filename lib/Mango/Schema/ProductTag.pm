# $Id: ProductTag.pm 1733 2007-02-14 03:06:56Z claco $
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

Mango::Schema::ProductTag - DBIC schema class for product tags

=head1 SYNOPSIS

    use Mango::Schema;
    my $schema = Mango::Schema->connect;
    my $prodct_tags = $schema->resultset('ProductTags')->search;

=head1 DESCRIPTION

Mango::Schema::ProductTag is loaded by Mango::Schema to read/write role
membership data.

=head1 COLUMNS

=head2 product_id

Contains the product id for each product/tag pivot record.

    product_id => {
        data_type      => 'INT',
        is_nullable    => 0,
        is_foreign_key => 1,
        extras         => {unsigned => 1}
    },

=head2 tag_id

Contains the tag id for each product/tag pivot record.

    tag_id => {
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
