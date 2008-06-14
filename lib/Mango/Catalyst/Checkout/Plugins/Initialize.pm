# $Id$
package Mango::Catalyst::Checkout::Plugins::Initialize;
use strict;
use warnings;

BEGIN {
    use base 'Handel::Checkout::Plugin';
    use Handel::Constants qw(:checkout);
}

sub register {
    my ( $self, $ctx ) = @_;

    $ctx->add_handler( 'INITIALIZE', \&initialize, 100 );

    return;
}

sub initialize {
    my ( $self, $ctx ) = @_;
    my $order   = $ctx->order;
    my $c       = $ctx->stash->{'c'};
    my $profile = $c->user->profile;

    use Carp ();
    Carp::carp 'INIT FROM MANGO CAT PLUGIN';

    ## this sohuld really be in core
    $order->billtofirstname( $profile->first_name );
    $order->billtolastname( $profile->last_name );
    $order->billtoemail( $profile->email );

    $order->shiptosameasbillto(1);
    $order->shiptofirstname( $profile->first_name );
    $order->shiptolastname( $profile->last_name );
    $order->shiptoemail( $profile->email );

    return CHECKOUT_HANDLER_OK;
}

1;
__END__

=head1 NAME

Mango::Catalyst::Checkout::Plugins::Initialize - Mango checkout plugin to copy profile to order

=head1 SYNOPSIS

    my $checkout = Mango::Checkout->new({
        phase => 'CHECKOUT_PHASE_INITIALIZE'
    });
    $checkout->process;

=head1 DESCRIPTION

Mango::Catalyst::Checkout::Plugins::Initialize copies the current users
profile into the specified order.

=head1 METHODS

=head2 initialize

Copies the users profile into the current order.

=head2 register

Registers the current plugin.

=head1 SEE ALSO

L<Handel::Checkout::Plugin>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
