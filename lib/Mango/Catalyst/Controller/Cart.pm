# $Id$
package Mango::Catalyst::Controller::Cart;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
    use Handel::Constants qw/:cart/;
    use Mango            ();
    use Path::Class::Dir ();

    __PACKAGE__->config(
        resource_name => 'mango/cart',
        form_directory =>
          Path::Class::Dir->new( Mango->share, 'forms', 'cart' )
    );
}

sub instance : Chained('/') PathPrefix CaptureArgs(0) {
    my ( $self, $c ) = @_;

    $c->stash->{'cart'} = $c->user->cart;

    return;
}

sub view : Chained('instance') PathPart('') Args(0) Template('cart/view') {
    my ( $self, $c ) = @_;

    return;
}

sub add : Chained('instance') Args(0) Template('cart/view') {
    my ( $self, $c ) = @_;
    my $form = $self->form;
    my $cart = $c->stash->{'cart'};
    my $product;

    $form->exists(
        'sku',
        sub {
            $product =
              $c->model('Products')->get_by_sku( $form->field('sku') );

            return $product ? 1 : 0;
        }
    );

    if ( $self->submitted && $self->validate->success ) {
        $cart->add(
            {
                sku         => $product->sku,
                description => $product->description,
                price       => $product->price,
                quantity    => $form->field('quantity')
            }
        );

        $c->res->redirect( $c->uri_for( $self->action_for('view') ) . '/' );
    }

    return;
}

sub clear : Chained('instance') Args(0) Template('cart/view') {
    my ( $self, $c ) = @_;
    my $form = $self->form;
    my $cart = $c->stash->{'cart'};

    if ( $self->submitted && $self->validate->success ) {
        $cart->clear;
    }

    $c->res->redirect( $c->uri_for( $self->action_for('view') ) . '/' );

    return;
}

sub save : Chained('instance') Args(0) Template('cart/view') {
    my ( $self, $c ) = @_;
    my $form = $self->form;
    my $cart = $c->stash->{'cart'};

    if ( !$c->user_exists ) {
        $c->stash->{'errors'} = [ $c->localize('LOGIN_REQUIRED') ];
        $c->detach;
    }

    if ( $self->submitted && $self->validate->success ) {
        my $wishlist = $c->model('Wishlists')->create(
            {
                user => $c->user->get_object,
                name => $form->field('name')
            }
        );

        foreach my $item ( $cart->items ) {
            $wishlist->add($item);
        }

        $cart->clear;

        $c->response->redirect(
            $c->uri_for_resource( 'mango/wishlists', 'list' ) . '/' );
    }

    return;
}

1;
__END__

=head1 NAME

Mango::Catalyst::Controller::Cart - Catalyst controller for cart information

=head1 SYNOPSIS

    package MyApp::Controller::Cart;
    use base 'Mango::Catalyst::Controller::Cart';

=head1 DESCRIPTION

Mango::Catalyst::Controller::Cart provides the web interface for shopping
cart information.

=head1 ACTIONS

=head2 add : /cart/add/

Adds and item to the cart.

=head2 clear : /cart/clear/

Removes all items from the cart.

=head2 index : /cart/

Displays the contents of the cart.

=head2 instance : /cart/

Loads the current users cart.

=head2 restore : /cart/restore/

Restores a wishlist into the cart.

=head1 SEE ALSO

L<Mango::Catalyst::Model::Carts>, L<Mango::Provider::Carts>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
