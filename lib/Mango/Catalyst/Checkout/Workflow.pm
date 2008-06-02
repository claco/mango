# $Id$
package Mango::Catalyst::Checkout::Workflow;
use strict;
use warnings;

BEGIN {
    use Moose;
    extends 'Class::Workflow';

    use Mango::Catalyst::Checkout::Workflow::State ();
}

sub BUILD {
    my ( $self, $hash ) = @_;

    foreach my $key ( keys %{$hash} ) {
        if ( my ($type) = ( $key =~ /^(state|transition)s$/ ) ) {
            foreach my $item ( @{ $hash->{$key} } ) {
                $self->$type(
                    ref $item
                    ? ( ( ref $item eq 'ARRAY' ) ? @{$item} : %{$item} )
                    : $item
                );
            }
        } else {
            $self->$key( $hash->{$key} );
        }
    }

    return;
}

has '+state_class' =>
  ( default => 'Mango::Catalyst::Checkout::Workflow::State' );

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Mango::Catalyst::Checkout::Workflow - Workflow class for the checkout process

=head1 SYNOPSIS

    sub foo : Local {
        my ($self, $c) = @_;
        my $wi = $self->workflow->new_instance;
        my $t = $wi->get_transition('bar');
        $wi = $t->apply($wi);
        ...
    }

=head1 DESCRIPTION

Mango::Catalyst::Checkout::Workflow provides the workflow for the checkout
process; determining which steps or pages happen in what order.

=head1 METHODS

=head2 BUILD

Parses the workflow config and creates new workflow/state objects.

=head1 SEE ALSO

L<Class::Workflow>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
