# $Id$
package Mango::Catalyst::Controller::Checkout;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;

    use Mango::Checkout       ();
    use Handel::Constants     ();
    use Scalar::Util          ();
    use Class::Workflow       ();
    use Class::Workflow::YAML ();

    $ENV{'HandelPluginPaths'} =
'Mango::Checkout::Plugins, Mango::Catalyst::Checkout::Plugins, MyApp::Checkout::Plugins';

    __PACKAGE__->config(
        resource_name => 'mango/checkout',
        form_directory =>
          Path::Class::Dir->new( Mango->share, 'forms', 'checkout' ),
        workflow => {
            initial_state => 'preview',
            states        => [
                {
                    name        => 'preview',
                    transitions => [
                        {
                            name     => 'edit',
                            to_state => 'edit'
                        }
                    ]
                },
                { name => 'edit' }
            ]
        }
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

        $c->stash->{'order'} = $order;

        return 1;
    }
}

sub index : Template('checkout/index') {
    my ( $self, $c ) = @_;

    $c->response->redirect(
        $c->uri_for_resource(
            'mango/checkout', 'instance',
            $self->workflow->new_instance->state
          )
          . '/'
    );

    return;
}

sub instance : Chained('/') PathPrefix Args(1) Template('checkout/index') {
    my ( $self, $c, $state ) = ( shift, shift, shift );
    my $w = $self->workflow;
    $w->initial_state($state);
    my $wi = $self->workflow->new_instance;

    if ( $self->workflow->get_state($state) ) {
        if ( $self->can($state) ) {
            $self->$state(@_);
        } else {
            $wi = [$wi->state->transitions]->[0]->apply($wi);
            warn $wi->state;

            $c->response->redirect(
                $c->uri_for_resource(
                    'mango/checkout', 'instance',
                    $wi->state
                  )
                  . '/'
            );
        }
    } else {
        $self->not_found;
    }

    return;
}

sub initialize {
    my $self  = shift;
    my $c     = $self->context;
    my $order = $self->order;

    Scalar::Util::weaken($c);
    $c->stash->{'c'} = $c;
    my $checkout = Mango::Checkout->new(
        {
            order  => $order,
            phases => 'CHECKOUT_PHASE_INITIALIZE',
            stash  => $c->stash
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

    if ( defined $c->stash->{'order'} ) {
        return $c->stash->{'order'};
    }

    if ( $c->session->{'__mango_order_id'} ) {
        $order =
          $c->model('Orders')
          ->search( { id => $c->session->{'__mango_order_id'} } )->first;

        $c->stash->{'order'} = $order;
    }

    if ( !$order ) {
        if ( $c->user_exists ) {
            $order = $c->model('Orders')->create(
                {
                    cart => $c->user->cart,
                    user => $c->user->id
                }
            );
        } else {
            $order =
              $c->model('Orders')->create( { cart => $c->user->cart } );
        }
        $c->session->{'__mango_order_id'} = $order->id;
        $c->stash->{'order'}              = $order;

        $self->initialize;
    }

    return $order;
}

sub workflow {
    my $self = shift;
    my $c    = $self->context;

    if ( !$self->{'workflow_instance'} ) {
        my $y        = Class::Workflow::YAML->new;
        my $workflow = Class::Workflow->new;

        $y->workflow_key('checkout');
        $y->inflate_hash( $workflow,
            defined $c->config->{'checkout'}
            ? $c->config
            : { checkout => $self->{'workflow'} } );

        $self->{'workflow_instance'} = $workflow;
    }

    return $self->{'workflow_instance'};
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

=head2 index : /checkout/

Initiates the checkout process into the first state, usually 'preview'.

=head2 instance : /checkout/<state>

Runs the specified checkout state.

=head1 METHODS

=head2 initialize

Routes the current order record through the INITIALIZE phase of the checkout
pipeline.

=head2 order

Returns the order for the users current checkout process.

=head1 SEE ALSO

L<Mango::Checkout>, L<Handel::Checkout>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
