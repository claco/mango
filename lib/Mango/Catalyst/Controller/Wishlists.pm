# $Id$
package Mango::Catalyst::Controller::Wishlists;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
    use Handel::Constants qw/:cart/;
    use Mango            ();
    use Path::Class::Dir ();

    __PACKAGE__->config(
        resource_name => 'mango/wishlists',
        form_directory =>
          Path::Class::Dir->new( Mango->share, 'forms', 'wishlists' )
    );
}

sub auto : Private {
    my ( $self, $c ) = @_;

    if ( !$c->user_exists ) {
        $c->response->status(401);
        $c->stash->{'template'} = 'errors/401';
        $c->detach;
    }

    return 1;
}

sub list : Chained('/') PathPrefix Args(0) Template('wishlists/list') {
    my ( $self, $c ) = @_;
    my $wishlists = $c->model('Wishlists')->search(
        { user => $c->user->id },
        {
            page => $self->current_page,
            rows => $self->entries_per_page
        }
    );
    my $pager = $wishlists->pager;

    $c->stash->{'wishlists'} = $wishlists;
    $c->stash->{'pager'}     = $pager;

    return;
}

sub instance : Chained('/') PathPrefix CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    my $wishlist = $c->model('Wishlists')->search(
        {
            user => $c->user->id,
            id   => $id
        }
    )->first;

    if ( defined $wishlist ) {
        $c->stash->{'wishlist'} = $wishlist;
    } else {
        $c->response->status(404);
        $c->detach;
    }

    return;
}

sub view : Chained('instance') PathPart('') Args(0) Template('wishlists/view')
{
    my ( $self, $c ) = @_;

    return;
}

sub clear : Chained('instance') PathPart Args(0) Template('wishlists/view') {
    my ( $self, $c ) = @_;
    my $form     = $self->form;
    my $wishlist = $c->stash->{'wishlist'};

    if ( $self->submitted && $self->validate->success ) {
        $wishlist->clear;
    }

    $c->response->redirect(
        $c->uri_for_resource( 'mango/wishlists', 'view', [ $wishlist->id ] )
          . '/' );

    return;
}

sub edit : Chained('instance') PathPart Args(0) Template('wishlists/edit') {
    my ( $self, $c ) = @_;
    my $wishlist = $c->stash->{'wishlist'};
    my $form     = $self->form;

    $form->values(
        {
            id          => $wishlist->id,
            name        => $wishlist->name,
            description => $wishlist->description,
            created     => $wishlist->created . '',
            updated     => $wishlist->updated . ''
        }
    );

    if ( $self->submitted && $self->validate->success ) {
        $wishlist->name( $form->field('name') );
        $wishlist->description( $form->field('description') );
        $wishlist->update;

        $form->values( { updated => $wishlist->updated . '' } );

        $c->response->redirect(
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

    if ( $self->submitted && $self->validate->success ) {
        $wishlist->destroy;

        $c->response->redirect(
            $c->uri_for_resource( 'mango/wishlists', 'index' ) . '/' );
    }

    return;
}

sub restore : Chained('instance') PathPart Args(0) Template('wishlists/view')
{
    my ( $self, $c ) = @_;
    my $form     = $self->form;
    my $wishlist = $c->stash->{'wishlist'};

    if ( $self->submitted && $self->validate->success ) {
        $c->user->cart->restore( $wishlist, $form->field('mode') );

        $c->response->redirect(
            $c->uri_for_resource( 'mango/cart', 'view' ) . '/' );
    }

    return;
}

1;
__END__

=head1 NAME

Mango::Catalyst::Controller::Wishlists - Catalyst controller for current users wishlists

=head1 SYNOPSIS

    package MyApp::Controller::Wishlists;
    use base 'Mango::Catalyst::Controller::Wishlists';

=head1 DESCRIPTION

Mango::Catalyst::Controller::Wishlists provides the web interface for the
current users wishlists.

=head1 ACTIONS

=head2 auto

Checks to see if the current user is authenticated and sends a 401 http status
code if they are not.

=head2 clear : /wishlists/<id>/clear/

Removes all items in the specified wishlist for the current user.

=head2 delete : /wishlists/<id>/delete/

Deletes the specified wishlist for the current user.

=head2 edit : /wishlists/<id>/edit/

Updates the specified wishlist for the current user.

=head2 instance : /wishlists/<id>/

Loads the specified wishlist for the current user.

=head2 list : /wishlists/

Displays a list of the wishlists for the current user.

=head2 restore : /wishlists/<id>/restore/

Copies the specified wishlists items in the current users cart.

=head2 view : /wishlists/<id>/

Displays the specified wishlist for the current user.

=head1 SEE ALSO

L<Mango::Catalyst::Model::Carts>, L<Mango::Provider::Carts>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
