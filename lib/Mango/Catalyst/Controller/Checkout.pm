# $Id$
package Mango::Catalyst::Controller::Checkout;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;

    use Mango::Checkout   ();
    use Handel::Constants ();

    __PACKAGE__->config(
        resource_name => 'mango/checkout',
        form_directory =>
          Path::Class::Dir->new( Mango->share, 'forms', 'checkout' )
    );
}

sub auto : Private {
    my ( $self, $c ) = @_;
    my $cart = $c->user->cart;

    if ( !$cart->count ) {
        $c->res->redirect(
            $c->uri_for_resource( 'mango/cart', 'view' ) . '/' );

        return;
    } elsif ( !$c->user_exists ) {
        $c->redirect_to_login;

        return;
    } else {
        my $order = $self->order;
        $order->reconcile($cart);
        $order->update;

        return 1;
    }
}

sub index : Template('checkout/index') {
    my ( $self, $c ) = @_;

    return;
}

sub instance : Chained('/') PathPrefix Args(1) Template('checkout/index') {
    my ( $self, $c, $state ) = @_;

    return;
}

sub initialize {
    my $self  = shift;
    my $c     = $self->context;
    my $order = $self->order;

    my $checkout = Mango::Checkout->new(
        {
            order  => $order,
            phases => 'CHECKOUT_PHASE_INITIALIZE'
        }
    );

    if ( $checkout->process != Handel::Constants::CHECKOUT_STATUS_OK ) {
        $c->stash->{'errors'} = $checkout->messages;
    } else {
        $order->update;
    }

    return;
}

sub order {
    my $self = shift;
    my $c    = $self->context;
    my $order;

    if ( $c->session->{'__mango_order_id'} ) {
        $order =
          $c->model('Orders')
          ->search( { id => $c->session->{'__mango_order_id'} } );
    }

    if ( !$order ) {
        if ( $c->user_exists ) {
            $order = $c->model('Orders')->create(
                {
                    cart => $c->user->cart,
                    user => $c->user
                }
            );
        } else {
            $order =
              $c->model('Orders')->create( { cart => $c->user->cart } );
        }
        $c->session->{'__mango_order_id'} = $order->id;

        $self->initialize;
    }

    return $order;
}

1;
__END__

=head1 NAME

Mango::Catalyst::Controller::Checkout - Catalyst controller for checkout

=head1 SYNOPSIS

    package MyApp::Controller::Checkout;
    use base 'Mango::Catalyst::Controller::Checkout';

=head1 DESCRIPTION

Mango::Catalyst::Controller::Checkout provides the web interface for the
checkout process.

=head1 ACTIONS

=head2 instance : /checkout/<state>

Runs the specified checkout state.

=head1 SEE ALSO

L<Mango::Checkout>, L<Handel::Checkout>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
