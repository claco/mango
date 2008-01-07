package Mango::Catalyst::Controller::Wishlists::Items;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
    use Handel::Constants qw/:cart/;
    use Mango ();
    use Path::Class::Dir ();

    __PACKAGE__->config(
        resource_name  => 'wishlists/items',
        form_directory => Path::Class::Dir->new(Mango->share, 'forms', 'wishlists', 'items')
    );
};

sub instance : Chained('../instance') PathPart('items') CaptureArgs(1) {
    my ($self, $c, $id) = @_;
    my $wishlist = $c->stash->{'wishlist'};
    my $item = $wishlist->items({
        id => $id
    })->first;

    if (defined $item) {
        $c->stash->{'item'} = $item;
    } else {
        $c->response->status(404);
        $c->detach;
    };
};

sub update : Chained('instance') PathPart Args(0) Template('wishlists/view') {
    my ($self, $c) = @_;
    my $form = $self->form;
    my $wishlist = $c->stash->{'wishlist'};
    my $item = $c->stash->{'item'};

    if ($self->submitted && $self->validate->success) {
        $item->quantity($form->field('quantity'));
        $item->update;

        $c->res->redirect(
            $c->uri_for_resource('wishlists', 'view', [$wishlist->id]) . '/'
        );
    };

    return;
};

sub delete : Chained('instance') PathPart Args(0) Template('wishlists/view') {
    my ($self, $c) = @_;
    my $form = $self->form;
    my $wishlist = $c->stash->{'wishlist'};
    my $item = $c->stash->{'item'};

    if ($self->submitted && $self->validate->success) {
        $wishlist->delete({
            id => $form->field('id')
        });

        $c->res->redirect(
            $c->uri_for_resource('wishlists', 'view', [$wishlist->id]) . '/'
        );
    };

    return;
};
 
1;