# $Id$
package Mango::Tag;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Object/;

    __PACKAGE__->mk_group_accessors('column', qw/name count/);
};

1;
__END__

=head1 NAME

Mango::Tag - A tag assigned to products

=head1 SYNOPSIS

    my $tags = $product->tags;
    while (my $tag = %tags->next) {
        print $tag->name;
    };

=head1 DESCRIPTION

Mango::Tag represents a tag assigned to products.

=head1 METHODS

=head2 id

Returns id of the current tag.

    print $tag->id;

=head2 created

Returns the date the tag was created as a DateTime object.

    print $tag->created;

=head2 updated

Returns the date the tag was last updated as a DateTime object.

    print $tag->updated;

=head2 count

Returns the number of instances this tag.

B<This is not currently implemented>.

=head2 name

=over

=item Arguments: $name

=back

Gets/sets the name of the tag itself.

    print $tag->name;

=head1 SEE ALSO

L<Mango::Object>, L<Mango::Product>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
