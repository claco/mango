package Mango::Catalyst::Controller::Cart;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller::Form Mango::Catalyst::Controller::REST/;
    use Handel::Constants qw/:cart/;
    use Mango ();
    use Path::Class ();

    __PACKAGE__->form_directory(
        Path::Class::Dir->new(Mango->share, 'forms', 'cart')
    );
};

sub COMPONENT {
    my $class = shift;
    my $self = $class->NEXT::COMPONENT(@_);
    $_[0]->config->{'mango'}->{'controllers'}->{'cart'} = $class;

    return $self;
};

sub begin : Private {
    my ($self, $c) = @_;

    $c->stash->{'cart'} = $c->user->cart;
};

sub index : Template('cart/index') {
    my ($self, $c) = @_;

    return;
};

sub add : Local Template('cart/index') {
    my ($self, $c) = @_;
    my $form = $self->form;
    my $product;

    $form->exists('sku', sub {
        $product = $c->model('Products')->get_by_sku($form->field('sku'));

        return $product ? 1 : 0;
    });

    if ($self->submitted && $self->validate->success) {
        $c->user->cart->add({
            sku => $product->sku,
            description => $product->description,
            price => $product->price,
            quantity => $form->field('quantity')
        });

        $c->res->redirect(
            $c->uri_for($self->action_for('index')) . '/'
        );
    };

    return;
};

sub clear : Local Template('cart/index') {
    my ($self, $c) = @_;
    my $form = $self->form;

    if ($self->submitted && $self->validate->success) {
        $c->user->cart->clear;
    };

    $c->res->redirect(
        $c->uri_for($self->action_for('index')) . '/'
    );

    return;
};

sub delete : Local Template('cart/index') {
    my ($self, $c) = @_;
    my $form = $self->form;

    if ($self->submitted && $self->validate->success) {
        $c->user->cart->delete({
            id => $form->field('id')
        });

        $c->res->redirect(
            $c->uri_for($self->action_for('index')) . '/'
        );
    };

    return;
};

sub restore : Local Template('cart/index') {
    my ($self, $c) = @_;

    if ($c->req->method eq 'POST') {
        if ($c->forward('validate')) {
            if (my $cart = $c->forward('create')) {
                $cart->restore({
                    id      => $c->req->param('id'),
                    shopper => $c->session->{'shopper'},
                    type    => CART_TYPE_SAVED
                }, $c->req->param('mode') || CART_MODE_APPEND);

                $c->res->redirect(
                    $c->uri_for($self->action_for('index')) . '/'
                );
            };
        } else {
            $c->forward('list');
        };
    } else {
        $c->res->redirect(
            $c->uri_for($self->action_for('index')) . '/'
        );
    };

    return;
};

sub save : Local Template('cart/index') {
    my ($self, $c) = @_;
    my $form = $self->form;

    if (!$c->user_exists) {
        $c->stash->{'errors'} = [$c->localize('LOGIN_REQUIRED')];
        $c->detach;
    };

    if ($self->submitted && $self->validate->success) {
        my $wishlist = $c->model('Wishlists')->create({
            user => $c->user->get_object,
            name => $form->field('name')
        });

        foreach my $item ($c->user->cart->items) {
            $wishlist->add($item);
        };

        $c->user->cart->clear;

        $c->res->redirect(
            $c->uri_for($c->controller(
                $c->config->{'mango'}->{'controllers'}->{'user'}->{'wishlists'}
            )->action_for('index')) . '/'
        );
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
            $c->uri_for($self->action_for('index')) . '/'
        );
    };

    return;
};

1;
__END__
