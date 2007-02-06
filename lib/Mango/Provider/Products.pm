# $Id$
package Mango::Provider::Products;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider::DBIC/;
    use Mango::Exception ();

    __PACKAGE__->mk_group_accessors('component_class', qw/attribute_class/);
};
__PACKAGE__->attribute_class('Mango::Attribute');
__PACKAGE__->result_class('Mango::Product');
__PACKAGE__->source_name('Products');

sub get_by_user {
    throw Mango::Exception('METHOD_NOT_IMPLEMENTED');
};

sub get_by_sku {
    my ($self, $sku) = @_;

    return $self->search({
        sku => $sku
    });
};

sub search {
    my ($self, $filter, $options) = @_;

    $filter  ||= {};
    $options ||= {};

    my $attributes = delete $options->{'attributes'};
    if ($attributes) {
        $options = {%{$options}, join => 'attributes', prefetch => 'attributes'}
    };

    ## yeah, I should fix this later...surprised it works
    my @results = map {
        $self->result_class->new({
            provider => $self,
            data => {
                $_->get_inflated_columns,
                attributes => Mango::Iterator->new(
                    {data => [
                        map {
                            $attributes ?
                                $self->attribute_class->new({
                                    provider => $self,
                                    data => {$_->get_inflated_columns}
                                })
                            : ()
                        } $_->attributes->all
                    ]}
                )
            }
        })
    } $self->resultset->search($filter, $options)->all;

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
