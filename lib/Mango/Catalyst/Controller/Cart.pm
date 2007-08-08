package Mango::Catalyst::Controller::Cart;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller::Form Mango::Catalyst::Controller::REST/;
    use Handel::Constants qw/:cart/;
};


sub begin : Private {
    my ($self, $c) = @_;

    $c->stash->{'cart'} = $c->user->cart;
};

sub index : Template('cart/index') {
    my ($self, $c) = @_;
};

sub add : Local {
    my ($self, $c) = @_;


    if ($c->req->method eq 'POST') {
        ## add magic to get from products model!!!
        $c->user->cart->add($c->req->params);
    };

    $c->res->redirect($c->uri_for('/cart/'));
};

sub clear : Local {
    my ($self, $c) = @_;

    if ($c->req->method eq 'POST') {
        $c->user->cart->clear;
    };

    $c->res->redirect($c->uri_for('/cart/'));
};

sub delete : Local Template('cart/index') {
    my ($self, $c) = @_;
    my $form = $self->form;

    if ($self->submitted && $self->validate->success) {
        $c->user->cart->delete({
            id => $form->field('id')
        });

        $c->res->redirect(
            $c->uri_for('/', $self->path_prefix . '/')
        );
    };

    return;
};

sub restore : Local {
    my ($self, $c) = @_;

    if ($c->req->method eq 'POST') {
        if ($c->forward('validate')) {
            if (my $cart = $c->forward('create')) {
                $cart->restore({
                    id      => $c->req->param('id'),
                    shopper => $c->session->{'shopper'},
                    type    => CART_TYPE_SAVED
                }, $c->req->param('mode') || CART_MODE_APPEND);

                $c->res->redirect($c->uri_for('/cart/'));
            };
        } else {
            $c->forward('list');
        };
    } else {
        $c->res->redirect($c->uri_for('/cart/'));
    };

    return;
};

sub save : Local {
    my ($self, $c) = @_;

    if ($c->req->method eq 'POST') {
        if ($c->forward('validate')) {
            $c->user->cart->name($c->req->param('name') || 'My Cart');
            $c->user->cart->save;

            $c->res->redirect($c->uri_for('/cart/list/'));
        };
    } else {
        $c->res->redirect($c->uri_for('/cart/'));
    };

    return;
};

sub update : Local Template('cart/index') {
    my ($self, $c) = @_;
    my $form = $self->form;

    if ($self->submitted && $self->validate->success) {
        my $item = $c->user->cart->items({
            id => $form->field('id')
        })->first;

        if ($item) {
            $item->quantity($form->field('quantity'));
            $item->update;
        };

        $c->res->redirect(
            $c->uri_for('/', $self->path_prefix . '/')
        );
    };

    return;
};

1;
__END__
