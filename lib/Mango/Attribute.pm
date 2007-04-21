# $Id$
package Mango::Attribute;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Object/;

    __PACKAGE__->mk_group_accessors('column', qw/name value/);
};

sub destroy {
    my $self = shift;

    return $self->meta->provider->delete_attributes(
        $self->meta->parent,
        {id => $self->id}
    );
};

sub update {
    my $self = shift;

    return $self->meta->provider->update_attribute($self);
};

1;
__END__

=head1 NAME

Mango::Attribute - Module representing a product attribute

=head1 SYNOPSIS

    my $attributes = $product->attributes;
    
    while (my $attribute = $attributes->next) {
        print $attribute->name, ': ', $attribute->value;
    };

=head1 DESCRIPTION

Mango::Attribute represents an attribute (name/value pair) of an individual
product.

=head1 METHODS

=head2 created

Returns the date and time in UTC the attribute was created as a DateTime
object.

    print $attribute->created;

=head2 destroy

Deletes the current attribute from the product to which it is assigned.

    $attribute->destroy;

=head2 id

Returns the id of the current attribute.

    print $attribute->id;

=head2 name

=over

=item Arguments: $name

=back

Gets/sets the name of the current attribute.

    print $attribute->name;

=head2 update

Saves any changes made to the attribute back to the provider.

    $attribute->value('Red');
    $attribute->update;

Whenever L</update> is called, L</updated> is automatically set to the
current time in UTC.

=head2 updated

Returns the date and time in UTC the attribute was last updated as a DateTime
object.

    print $attribute->updated;

=head2 value

=over

=item Arguments: $value

=back

Gets/sets the value of the current attribute.

    print $attribute->value;

=head1 SEE ALSO

L<Mango::Object>, L<Mango::Product>, L<Mango::Provider::Products>, L<DateTime>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/

