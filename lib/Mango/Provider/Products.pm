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
__PACKAGE__->tag_source_name('Tags');
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
        {'tag.name' => \@tags}, {
            distinct => 1,
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

sub create {
    my ($self, $data) = (shift, shift);
    my $attributes = delete $data->{'attributes'};
    my $tags = delete $data->{'tags'};
    my $product = $self->SUPER::create($data, @_);

    if ($attributes) {
        $product->add_attributes(@{$attributes});
    };
    if ($tags) {
        $product->add_tags(@{$tags});
    };

    return $product;
};

sub add_attribute {
    my @attributes = shift->add_attributes(@_);

    return shift @attributes;
};

sub add_attributes {
    my ($self, $product, @data) = @_;
    my $resultset = $self->schema->resultset($self->attribute_source_name);
    my @added;

    foreach my $attribute (@data) {
        if (Scalar::Util::blessed $attribute && $attribute->isa('Mango::Attribute')) {
            $attribute = {%{$attribute->data}};
        };
        $attribute->{'product_id'} = $product->id;

        push @added, $self->attribute_class->new({
            provider => $self,
            product => $product,
            data => {$resultset->update_or_create($attribute, {key => 'product_attribute_name'})->get_inflated_columns}
        });
    };

    return @added;
};

sub search_attributes {
    my ($self, $product, $filter, $options) = @_;

    $filter ||= {};
    $options ||= {};

    $filter->{'product_id'} = $product->id;

    my @results = map {
        $self->attribute_class->new({
            provider => $self,
            product => $product,
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
    my ($self, $product, $filter, $options) = @_;
    my $resultset = $self->schema->resultset($self->attribute_source_name);

    $filter ||= {};
    $options ||= {};

    $filter->{'product_id'} = $product->id;

    return $resultset->search(
        $filter, $options
    )->delete_all;
};

sub update_attribute {
    my ($self, $attribute) = @_;
    my $resultset = $self->schema->resultset($self->attribute_source_name);

    return $resultset->find($attribute->id)->update(
        {%{$attribute->data}}
    );
};

sub add_tag {
    my @tags = shift->add_tags(@_);

    return shift @tags;
};

sub add_tags {
    my ($self, $product, @data) = @_;
    my $resultset = $self->schema->resultset($self->tag_source_name);
    my @added;

    foreach my $tag (@data) {
        if (Scalar::Util::blessed $tag && $tag->isa('Mango::Tag')) {
            $tag = {%{$tag->data}};
        } elsif (!ref $tag) {
            $tag = {name => $tag};
        };

        my $newtag = $resultset->find_or_create($tag);
        $newtag->related_resultset('map_product_tag')->find_or_create({
            product_id => $product->id,
            tag_id => $newtag->id
        });
        push @added, $self->tag_class->new({
            provider => $self,
            data => {$newtag->get_inflated_columns}
        });
    };

    return @added;
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

sub delete_tags {
    my ($self, $product, $filter, $options) = @_;
    my $resultset = $self->schema->resultset($self->tag_source_name);

    $filter ||= {};
    $options ||= {};

    return $resultset->search(
        $filter, $options
    )->related_resultset('map_product_tag')->search({
        'product_id' => $product->id
    })->delete_all;
};

1;
__END__
