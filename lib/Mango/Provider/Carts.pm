# $Id$
package Mango::Provider::Carts;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider/;
    use Handel::Constants qw/CART_TYPE_TEMP/;

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

    return $self->storage->create(@_);
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

    return $self->storage->destroy(@_);
};

1;
__END__
