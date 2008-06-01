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
                    ? ( ( ref $item eq "ARRAY" ) ? @{$item} : %{$item} )
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
