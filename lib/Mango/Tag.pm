# $Id$
package Mango::Tag;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Object/;
    use Mango::Exception ();

    __PACKAGE__->mk_group_accessors('column', qw/name/);
};

sub count {
    return shift->{'count'} || 0;
};

sub destroy {
    Mango::Exception->throw('METHOD_NOT_IMPLEMENTED');
};

1;
__END__

=head1 NAME

Mango::Tag - Module representing a [folksonomy] tag

=head1 SYNOPSIS

    my $tags = $product->tags;
    
    while (my $tag = %tags->next) {
        print $tag->name;
    };

=head1 DESCRIPTION

Mango::Tag represents a tag assigned to products.

=head1 METHODS

=head2 count

Returns the number of instances this tag.

B<This is not currently implemented and always returns 0>.

=head2 created

Returns the date and time in UTC the tag was created as a DateTime
object.

    print $user->created;

=head2 destroy

B<This is not currently implemented>.

=head2 id

Returns the id of the current tag.

    print $tag->id;

=head2 name

=over

=item Arguments: $name

=back

Gets/sets the name of the current tag.

    print $tag->name;

=head2 updated

Returns the date and time in UTC the tag was last updated as a DateTime
object.

    print $user->updated;

=head1 SEE ALSO

L<Mango::Object>, L<Mango::Product>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
