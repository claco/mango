# $Id$
package Mango::Catalyst::Controller::Cart::Items;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
    use Handel::Constants qw/:cart/;
    use Mango            ();
    use Path::Class::Dir ();

    __PACKAGE__->config(
        resource_name => 'mango/cart/items',
        form_directory =>
          Path::Class::Dir->new( Mango->share, 'forms', 'cart', 'items' )
    );
}

sub instance : Chained('../instance') PathPart('items') CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    my $cart = $c->stash->{'cart'};
    my $item = $cart->items( { id => $id } )->first;

    if ( defined $item ) {
        $c->stash->{'item'} = $item;
    } else {
        $c->response->status(404);
        $c->detach;
    }

    return;
}

sub update : Chained('instance') PathPart Args(0) Template('cart/index') {
    my ( $self, $c ) = @_;
    my $form = $self->form;
    my $item = $c->stash->{'item'};

    if ( $self->submitted && $self->validate->success ) {
        $item->quantity( $form->field('quantity') );
        $item->update;

        $c->res->redirect( $c->uri_for_resource('mango/cart') . '/' );
    }

    return;
}

sub delete : Chained('instance') PathPart Args(0) Template('cart/index') {
    my ( $self, $c ) = @_;
    my $form = $self->form;
    my $cart = $c->stash->{'cart'};
    my $item = $c->stash->{'item'};

    if ( $self->submitted && $self->validate->success ) {
        $cart->delete( { id => $item->id } );

        $c->res->redirect( $c->uri_for_resource('mango/cart') . '/' );
    }

    return;
}

1;
__END__

=head1 NAME

Mango::Catalyst::Controller::Carts::Items - Catalyst controller for cart item information

=head1 SYNOPSIS

    package MyApp::Controller::Cart::Items;
    use base 'Mango::Catalyst::Controller::Cart::Items';

=head1 DESCRIPTION

Mango::Catalyst::Controller::Carts::Items provides the web interface for
shopping cart items.

=head1 ACTIONS

=head2 delete : /cart/items/<id>/delete/

Removes the specified item from the current cart.

=head2 instance : /cart/items/<id>

Loads the specified cart item form the current cart.

=head2 update : /cart/items/<id>/update/

Updates the specified item in the current cart.

=head1 SEE ALSO

L<Mango::Catalyst::Controller::Carts>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
