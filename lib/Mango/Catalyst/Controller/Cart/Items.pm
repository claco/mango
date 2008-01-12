package Mango::Catalyst::Controller::Cart::Items;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
    use Handel::Constants qw/:cart/;
    use Mango ();
    use Path::Class::Dir ();

    __PACKAGE__->config(
        resource_name  => 'mango/cart/items',
        form_directory => Path::Class::Dir->new(Mango->share, 'forms', 'cart', 'items')
    );
};

sub instance : Chained('../instance') PathPart('items') CaptureArgs(1) {
    my ($self, $c, $id) = @_;
    my $cart = $c->stash->{'cart'};
    my $item = $cart->items({
        id => $id
    })->first;

    if (defined $item) {
        $c->stash->{'item'} = $item;
    } else {
        $c->response->status(404);
        $c->detach;
    };
};

sub update : Chained('instance') PathPart Args(0) Template('cart/index') {
    my ($self, $c) = @_;
    my $form = $self->form;
    my $item = $c->stash->{'item'};

    if ($self->submitted && $self->validate->success) {
        $item->quantity($form->field('quantity'));
        $item->update;

        $c->res->redirect(
            $c->uri_for_resource('mango/cart') . '/'
        );
    };

    return;
};

sub delete : Chained('instance') PathPart Args(0) Template('cart/index') {
    my ($self, $c) = @_;
    my $form = $self->form;
    my $cart = $c->stash->{'cart'};
    my $item = $c->stash->{'item'};

    if ($self->submitted && $self->validate->success) {
        $cart->delete({
            id => $item->id
        });

        $c->res->redirect(
            $c->uri_for_resource('mango/cart') . '/'
        );
    };

    return;
};

1;