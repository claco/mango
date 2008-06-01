# $Id$
package Mango::Catalyst::Checkout::Workflow::State;
use strict;
use warnings;

BEGIN {
    use Moose;
    use Moose::Util::TypeConstraints;
    use Mango::Checkout ();

    extends 'Class::Workflow::State::Simple';
}

sub BUILD {
    my ($self, $hash) = @_;

    $self->checkout($hash);
}

subtype 'Checkout' => as 'Object' => where { $_->isa('Mango::Checkout') };

coerce 'Checkout' => from 'HashRef' => via { Mango::Checkout->new($_) };

has 'checkout' => (
    isa    => 'Checkout',
    is     => 'rw',
    coerce => 1
);

__PACKAGE__->meta->make_immutable;

1;
