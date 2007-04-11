# $Id: Carts.pm 1785 2007-03-26 02:00:56Z claco $
package Mango::Provider::Carts;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider/;

    __PACKAGE__->mk_group_accessors('simple', qw/storage/);
};
__PACKAGE__->result_class('Mango::Cart');

sub setup {
    my ($self, $args) = @_;
    my $storage = $self->result_class->storage->clone;

    $storage->setup($args);

    $self->storage(
        bless {storage => $storage}, $self->result_class
    );

    return;
};

sub create {
    my $self = shift;
    my $data = shift || {};

    return $self->storage->create($data, @_);
};

sub get_by_user {
    my $self = shift;
    my $object = shift;
    my $id = Scalar::Util::blessed($object) ? $object->id : $object ;

    return $self->search({user_id => $id}, @_);
};

sub search {
    my $self = shift;

    return $self->storage->search(@_);
};

sub update {
    my ($self, $object) = @_;

    return $object->update;
};

sub delete {
    my $self = shift;
    my $filter = shift;

    if (Scalar::Util::blessed $filter) {
        $filter = {id => $filter->id};
    } elsif (ref $filter ne 'HASH') {
        $filter = {id => $filter};
    };

    return $self->storage->destroy($filter, @_);
};

1;
__END__
