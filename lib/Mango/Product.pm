# $Id$
package Mango::Product;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Object/;

    __PACKAGE__->mk_group_accessors( 'column',
        qw/sku name description price/ );
}

sub add_attribute {
    my $self = shift;

    return $self->meta->provider->add_attribute( $self, @_ );
}

sub add_attributes {
    my $self = shift;

    return $self->meta->provider->add_attributes( $self, @_ );
}

sub attributes {
    my $self = shift;

    return $self->meta->provider->search_attributes( $self, @_ );
}

sub delete_attributes {
    my $self = shift;

    return $self->meta->provider->delete_attributes( $self, @_ );
}

sub add_tag {
    my $self = shift;

    return $self->meta->provider->add_tag( $self, @_ );
}

sub add_tags {
    my $self = shift;

    return $self->meta->provider->add_tags( $self, @_ );
}

sub tags {
    my $self = shift;

    return $self->meta->provider->search_tags( $self, @_ );
}

sub delete_tags {
    my $self = shift;

    return $self->meta->provider->delete_tags( $self, @_ );
}

1;
__END__

=head1 NAME

Mango::Product - Module representing a product

=head1 SYNOPSIS

    my $product = $provider->get_by_sku('ABC-123');
    print $product->created;
    
    my $attributes = $product->attributes;
    while (my $attribute = $attributes->next) {
        print $attribute->name, ': ', $attribute->value;
    };

=head1 DESCRIPTION

Mango::Product represents a product to be sold.

=head1 METHODS

=head2 add_attribute

Same as L</add_attributes>.

=head2 add_attributes

=over

=item Arguments: @attributes

=back

Adds an attribute to the current product. C<atttributes> may be hashes
containing name/value data, or Mango::Attribute objects;

    $product->add_attributes(
        {name => 'Color', value => 'red'},
        $attributeobject
    );

=head2 add_tag

Same as L</add_tag>.

=head2 add_tags

=over

=item Arguments: @tags

=back

Adds tags to the current product. C<tags> may be tag strings, or Mango::Tag
objects:

    $product->add_tags(
        'computers',
        $tagobject
    );

=head2 attributes

=over

=item Arguments: $filter, $options

=back

Returns a list of attributes for the current product in list context, or a
Mango::Iterator in scalar context.

    my @attributes = $product->attributes({
        name => 'A%'
    });
    
    my $iterator = $product->attributes({
        name => 'A%'
    });

=head2 created

Returns the date and time in UTC the product was created as a DateTime
object.

    print $profile->created;

=head2 delete_attribute

Sames as L</delete_attributes>.

=head2 delete_attributes

=over

=item Arguments: $filter

=back

Deletes attributes from the current product matching the supplied filter..

    $product->delete_attributes({
        name => 'Color'
    });

=head2 delete_tag

Sames as L</delete_tags>.

=head2 delete_tags

=over

=item Arguments: $filter

=back

Deletes tags from the current product matching the supplied filter..

    $product->delete_tags({
        'computer'
    });

=head2 description

=over

=item Arguments: $description

=back

Gets/sets the description of the current product.

    print $product->description;

=head2 destroy

Deletes the current profile.

=head2 id

Returns the id of the current product.

    print $product->id;

=head2 name

=over

=item Arguments: $name

=back

Gets/sets the name of the current product.

    print $product->name;

=head2 price

=over

=item Arguments: $price

=back

Gets/sets the price of the current product. The price is returned as a
L<Mango::Currency|Mango::Currency> object.

    print $product->price;

=head2 sku

=over

=item Arguments: $sku

=back

Gets/sets the sku/part number of the current product.

    print $product->sku;

=head2 tags

=over

=item Arguments: $filter, $options

=back

Returns a list of tags for the current product in list context, or a
Mango::Iterator in scalar context.

    my @tags = $product->tags({
        name => 'A%'
    });
    
    my $iterator = $product->tags({
        name => 'A%'
    });

=head2 update

Saves any changes made to the product back to the provider.

    $product->password('Red');
    $product->update;

Whenever L</update> is called, L</updated> is automatically set to the
current time in UTC.

=head2 updated

Returns the date and time in UTC the product was last updated as a DateTime
object.

    print $product->updated;

=head1 SEE ALSO

L<Mango::Object>, L<Mango::Provider::Profiles>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
