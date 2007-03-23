# $Id: Roles.pm 1745 2007-03-05 00:10:45Z claco $
package Mango::Provider::Tags;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider::DBIC/;
    use Scalar::Util ();
};
__PACKAGE__->result_class('Mango::Tag');
__PACKAGE__->source_name('Tags');

sub get_by_user {
    throw Mango::Exception('METHOD_NOT_IMPLEMENTED');
};

sub get_related_tags {
    my ($self, @tags) = @_;
warn "TAGS", @tags;
    my $resultset = $self->resultset->search({
        'tag_2.name' => [map {{'=' => $_}} @tags],

    }, {
        distinct => 1,
        join => [
            {'products' => { map_product_tag => 'tag'}},
            {'products' => { map_product_tag => 'tag'}},
        ]
    });

    my @results = map {
        $self->result_class->new({
            provider => $self,
            data     => {$_->get_inflated_columns}
        })
    } $resultset->all;

    if (wantarray) {
        return @results;
    } else {
        return Mango::Iterator->new({
            data  => \@results
        });
    };
};

1;
__END__
