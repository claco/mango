# $Id$
package Mango::Provider::Users;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider::DBIC/;
    use Scalar::Util ();
};
__PACKAGE__->result_class('Mango::User');
__PACKAGE__->source_name('Users');

sub get_by_user {
    my $self = shift;
    my $object = shift;
    my $id = Scalar::Util::blessed($object) ? $object->id : $object ;

    return $self->search({id => $id}, @_);
};

1;
__END__
