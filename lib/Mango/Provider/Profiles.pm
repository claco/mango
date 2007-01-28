# $Id$
package Mango::Provider::Profiles;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider::DBIC/;
};
__PACKAGE__->result_class('Mango::Profile');
__PACKAGE__->source_name('Profiles');

sub get_by_user {
    my $self = shift;
    my $object = shift;
    my $id = Scalar::Util::blessed($object) ? $object->id : $object ;

    my $result = $self->resultset->find_or_create({user_id => $id}, @_);

    return $self->result_class->new({
        provider => $self,
        data => {$result->get_columns}
    });
};

1;
__END__
