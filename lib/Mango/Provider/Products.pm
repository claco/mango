# $Id$
package Mango::Provider::Products;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider::DBIC/;
    use Mango::Exception ();
    use Scalar::Util ();

    __PACKAGE__->mk_group_accessors('component_class', qw/attribute_class tag_class/);
    __PACKAGE__->mk_group_accessors('inherited', qw/attribute_source_name tag_source_name/);
};
__PACKAGE__->attribute_class('Mango::Attribute');
__PACKAGE__->attribute_source_name('ProductAttributes');
__PACKAGE__->tag_class('Mango::Tag');
__PACKAGE__->tag_source_name('ProductsTags');
__PACKAGE__->result_class('Mango::Product');
__PACKAGE__->source_name('Products');

sub get_by_user {
    throw Mango::Exception('METHOD_NOT_IMPLEMENTED');
};

sub get_by_sku {
    my ($self, $sku) = @_;

    return $self->search({
        sku => $sku
    })->first;
};

sub get_by_tags {
    my ($self, @tags) = @_;

    my @results = map {
        $self->result_class->new({
            provider => $self,
            data => {$_->get_inflated_columns}
        })
    } $self->resultset->search(
        [map({'tag.name' => $_}, @tags)], {
            join => {'map_product_tag' => 'tag'}
        }
    );

    if (wantarray) {
        return @results;
    } else {
        return Mango::Iterator->new({
            data => \@results
        });
    };
};

sub create_attribute {
    my ($self, $product, $data) = @_;
    my $resultset = $self->schema->resultset($self->attribute_source_name);

    if (Scalar::Util::blessed $data && $data->isa('Mango::Attribute')) {
        $data = {$data->data};
    };
    $data->{'product_id'} = $product->id;

    return $resultset->create($data);
};

sub search_attributes {
    my ($self, $product, $filter, $options) = @_;

    $filter ||= {};
    $options ||= {};

    $filter->{'product_id'} = $product->id;

    my @results = map {
        $self->attribute_class->new({
            provider => $self,
            data => {$_->get_inflated_columns}
        })
    } $self->schema->resultset($self->attribute_source_name)->search(
        $filter, $options
    )->all;

    if (wantarray) {
        return @results;
    } else {
        return Mango::Iterator->new({
            data => \@results
        });
    };
};

sub delete_attributes {
    my ($self, $filter, $options) = @_;
    my $resultset = $self->schema->resultset($self->attribute_source_name);

    $filter ||= {};
    $options ||= {};

    return $resultset->search(
        $filter, $options
    )->all;
};

sub update_attribute {
    my ($self, $attribute) = @_;
    my $resultset = $self->schema->resultset($self->attribute_source_name);

    return $resultset->find($attribute->id)->update(
        {%{$attribute->data}}
    );
};

sub search_tags {
    my ($self, $product, $filter, $options) = @_;

    $filter ||= {};
    $options ||= {};

    my @results = map {
        $self->tag_class->new({
            provider => $self,
            data => {$_->get_inflated_columns}
        })
    } $self->schema->resultset('ProductTags')->search({
        'product_id' => $product->id
    })->related_resultset('tag')->search(
        $filter, $options
    )->all;

    if (wantarray) {
        return @results;
    } else {
        return Mango::Iterator->new({
            data => \@results
        });
    };
};

1;
__END__
