# $Id$
package Mango::Catalyst::Controller::Wishlists::Items;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
    use Handel::Constants qw/:cart/;
    use Mango            ();
    use Path::Class::Dir ();

    __PACKAGE__->config(
        resource_name  => 'mango/wishlists/items',
        form_directory => Path::Class::Dir->new(
            Mango->share, 'forms', 'wishlists', 'items'
        )
    );
}

sub instance : Chained('../instance') PathPart('items') CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    my $wishlist = $c->stash->{'wishlist'};
    my $item = $wishlist->items( { id => $id } )->first;

    if ( defined $item ) {
        $c->stash->{'item'} = $item;
    } else {
        $c->response->status(404);
        $c->detach;
    }

    return;
}

sub update : Chained('instance') PathPart Args(0) Template('wishlists/view') {
    my ( $self, $c ) = @_;
    my $form     = $self->form;
    my $wishlist = $c->stash->{'wishlist'};
    my $item     = $c->stash->{'item'};

    if ( $self->submitted && $self->validate->success ) {
        $item->quantity( $form->field('quantity') );
        $item->update;

        $c->res->redirect(
            $c->uri_for_resource( 'mango/wishlists', 'view',
                [ $wishlist->id ] )
              . '/'
        );
    }

    return;
}

sub delete : Chained('instance') PathPart Args(0) Template('wishlists/view') {
    my ( $self, $c ) = @_;
    my $form     = $self->form;
    my $wishlist = $c->stash->{'wishlist'};
    my $item     = $c->stash->{'item'};

    if ( $self->submitted && $self->validate->success ) {
        $wishlist->delete( { id => $item->id } );

        $c->res->redirect(
            $c->uri_for_resource( 'mango/wishlists', 'view',
                [ $wishlist->id ] )
              . '/'
        );
    }

    return;
}

1;
__END__

=head1 NAME

Mango::Catalyst::Controller::Wishlists::Items - Catalyst controller for wishlist item information

=head1 SYNOPSIS

    package MyApp::Controller::Wishlists::Items;
    use base 'Mango::Catalyst::Controller::Wishlists::Items';

=head1 DESCRIPTION

Mango::Catalyst::Controller::Wishlists::Items provides the web interface for
the current users wishlist items.

=head1 ACTIONS

=head2 delete : /wishlists/<id>/items/<id>/delete/

Removes the specified item from the specified wishlist.

=head2 instance : /wishlists/<id>/items/<id>/

Loads the specified wishlist item form the specified wishlist.

=head2 update : /wishlists/<id>/items/<id>/update/

Updates the specified item in the specified wishlist.

=head1 SEE ALSO

L<Mango::Catalyst::Controller::Wishlists>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
