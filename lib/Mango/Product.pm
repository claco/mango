# $Id: Product.pm 1736 2007-02-18 19:44:43Z claco $
package Mango::Product;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Object/;

    __PACKAGE__->mk_group_accessors('column', qw/sku name description price/);
};

sub add_attribute {
    my $self = shift;

    return $self->provider->add_attribute($self, @_);
};

sub add_attributes {
    my $self = shift;

    return $self->provider->add_attributes($self, @_);
};

sub attributes {
    my $self = shift;

    return $self->provider->search_attributes($self, @_);
};

sub delete_attributes {
    my $self = shift;

    return $self->provider->delete_attributes($self, @_);
};

sub add_tag {
    my $self = shift;

    return $self->provider->add_tag($self, @_);
};

sub add_tags {
    my $self = shift;

    return $self->provider->add_tags($self, @_);
};

sub tags {
    my $self = shift;

    return $self->provider->search_tags($self, @_);
};

sub delete_tags {
    my $self = shift;

    return $self->provider->delete_tags($self, @_);
};

1;
__END__

=head1 NAME

Mango::Product - A product

=head1 SYNOPSIS

    my $product = $provider->get_by_sku('ABC-123');
    print $product->created;
    
    my $attributes = $product->attributes;
    while (my $attribute = $attributes->next) {
        print $attribute->name, ': ', $attribute->value;
    };

=head1 DESCRIPTION

Mango::Product represents a product returned from the products provider.

=head1 METHODS

=head2 add_attributes

=over

=item Arguments: @attributes

=back

Adds attribute to the product. C<atttributes> may be hashes containing
name/value data, or Mango::Attribute objects;

    $product->add_attributes(
        {name => 'Color', value => 'red'},
        $attributeobject
    );

=head2 add_attribute

Same as C<add_attributes>.

=head2 add_tags

=over

=item Arguments: @tags

=back

Adds tags to the product. C<tags> may be tag strings, or Mango::Tag objects;

    $product->add_tags(
        'computers',
        $tagobject
    );

=head2 add_tag

Same as C<add_tag>.

=head2 attributes

=over

=item Arguments: $filter, $options

=back

Returns a list of attributes for the product in list context, or a
Mango::Iterator in scalar context.

    my @attributes = $product->attributes({
        name => 'A%'
    });
    
    my $iterator = $product->attributes({
        name => 'A%'
    });

=head2 delete_attributes

=over

=item Arguments: $filter

=back

Deletes attributes for the product matching the supplied filter..

    $product->delete_attributes({
        name => 'Color'
    });

=head2 delete_attribute

Sames as C<delete_attributes>.

=head2 id

Returns id of the current product.

    print $product->id;

=head2 created

Returns the date the product was created as a DateTime object.

    print $product->created;

=head2 updated

Returns the date the product was last updated as a DateTime object.

    print $product->updated;

=head2 sku

=over

=item Arguments: $sku

=back

Gets/sets the sku/part number of the product.

    print $product->sku;

=head2 name

=over

=item Arguments: $name

=back

Gets/sets the name of the product.

    print $product->description;

=head2 price

=over

=item Arguments: $price

=back

Gets/sets the price of the product.

    print $product->price;

=head2 tags

=over

=item Arguments: $filter, $options

=back

Returns a list of tags for the product in list context, or a
Mango::Iterator in scalar context.

    my @tags = $product->tags({
        name => 'A%'
    });
    
    my $iterator = $product->tags({
        name => 'A%'
    });

=head2 delete_tags

=over

=item Arguments: $filter

=back

Deletes tags from the product matching the supplied filter..

    $product->delete_tags({
        'computer'
    });

=head2 delete_tag

Sames as C<delete_tags>.

=head2 update

Saves any changes to the profile back to the provider.

=head1 SEE ALSO

L<Mango::Object>, L<Mango::Provider::Profiles>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
