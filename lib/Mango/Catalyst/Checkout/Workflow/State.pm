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
    my ( $self, $hash ) = @_;

    $self->checkout($hash);

    return;
}

subtype 'Checkout' => as 'Object' => where { $_->isa('Mango::Checkout') };

coerce 'Checkout' => from 'HashRef' => via { Mango::Checkout->new($_) };

has 'checkout' => (
    isa    => 'Checkout',
    is     => 'rw',
    coerce => 1
);

has 'template' => (
    isa => 'Str',
    is  => 'rw'
);

sub short_name {
    my $self = shift;
    my ($name) = ( $self->name =~ /^(.*)_/ );

    $name ||= $self->name;

    return $name;
}

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Mango::Catalyst::Checkout::Workflow::State - Workflow state class for the checkout process

=head1 SYNOPSIS

    sub foo : Local {
        my ($self, $c) = @_;
        my $wi = $self->workflow->new_instance;
        my $t = $wi->get_transition('bar');
        $wi = $t->apply($wi);
        ...
    }

=head1 DESCRIPTION

Mango::Catalyst::Checkout::Workflow::State provides the workflow state for
the checkout process; determining which steps or pages happen in what order.

=head1 METHODS

=head2 BUILD

Parses the workflow config and creates new workflow/state objects.

=head2 short_name

Gets the shortened state name with the _HTTP_METHOD stripped from the end.

=head1 SEE ALSO

L<Class::Workflow>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
