# $Id$
package Mango::Attribute;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Object/;

    __PACKAGE__->mk_group_accessors('simple', qw/product/);
    __PACKAGE__->mk_group_accessors('column', qw/name value/);
};

sub destroy {
    my $self = shift;
    my $filter = shift;

    $filter ||= {};
    $filter->{'id'} = $self->id;

    return $self->provider->delete_attributes($self->product, $filter, @_);
};

sub update {
    my $self = shift;

    return $self->provider->update_attribute($self);
};

1;
__END__

=head1 NAME

Mango::Attribute - A product attribute

=head1 SYNOPSIS

    my $attributes = $product->attributes;
    while (my $attribute = $attributes->next) {
        print $attribute->name, $attribute->value;
    };

=head1 DESCRIPTION

Mango::Attribute represents a name/value pair about a specific product.

=head1 METHODS

=head2 id

Returns id of the current attribute.

    print $attribute->id;

=head2 created

Returns the date the attribute was created as a DateTime object.

    print $attribute->created;

=head2 updated

Returns the date the attribute was last updated as a DateTime object.

    print $attribute->updated;

=head2 name

=over

=item Arguments: $name

=back

Gets/sets the name of the user.

    print $attribute->name;

=head2 value

=over

=item Arguments: $value

=back

Gets/sets the value of the attribute.

    print $attribute->value;

=head2 update

Saves any changes to the attribute back to the provider.

=head1 SEE ALSO

L<Mango::Object>, L<Mango::Product>, L<Mango::Provider::Products>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/

