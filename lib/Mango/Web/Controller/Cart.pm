package Mango::Web::Controller::Cart;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Web::Controller::REST/;
    use Handel::Constants qw/:cart/;
    use FormValidator::Simple 0.17;
    use YAML;
};

=head1 NAME

Mango::Web::Controller::Cart - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 COMPONENT

=cut

sub COMPONENT {
    my $self = shift->NEXT::COMPONENT(@_);

    $self->{'validator'} = FormValidator::Simple->new;
    $self->{'validator'}->set_messages(
        $_[0]->path_to('root', 'forms', 'cart', 'messages.yml')
    );

    $self->{'profiles'} = YAML::LoadFile($_[0]->path_to('root', 'forms', 'cart', 'profiles.yml'));

    return $self;
};

=head2 default 

Default action when browsing to /cart/. If no session exists no cart will be
loaded. This keeps non-shoppers like Google and others from wasting sessions
and cart records for no good reason.

=cut

sub begin : Private {
    my ($self, $c) = @_;    
    $c->stash->{'template'} = 'cart/default';

    if ($c->sessionid) {
        my $cart = $c->user->cart;

        $c->stash->{'cart'} = $cart;
        $c->stash->{'items'} = $cart->items;
    };

    $self->NEXT::begin($c);
};

sub default : Private {
    my ($self, $c) = @_;

    return;
};

=head2 add

=over

=item Parameters: (See L<Handel::Cart/add>)

=back

Adds an item to the current cart during POST.

    /cart/add/

=cut

sub add : Local {
    my ($self, $c) = @_;
    
    if ($c->req->method eq 'POST') {
        ## add magic to get from products model!!!
        $c->user->cart->add($c->req->params);
    };

    $c->res->redirect($c->uri_for('/cart/'));
};

=head2 clear

Clears all items form the current shopping cart during POST.

    /cart/clear/

=cut

sub clear : Local {
    my ($self, $c) = @_;

    if ($c->req->method eq 'POST') {
        $c->user->cart->clear;
    };

    $c->res->redirect($c->uri_for('/cart/'));
};

=head2 delete

=over

=item Parameters: id

=back

Deletes an item from the current shopping cart during a POST.

    /cart/delete/

=cut

sub delete : Local {
    my ($self, $c) = @_;

    if ($c->req->method eq 'POST') {
        if ($c->forward('validate')) {
            $c->user->cart->delete({
                id => $c->req->params->{'id'}
            });

            $c->res->redirect($c->uri_for('/cart/'));
        };
    } else {
        $c->res->redirect($c->uri_for('/cart/'));
    };

    return;
};

=head2 restore

=over

=item Parameters: id

=back

Restores a saved shopping cart into the shoppers current cart during a POST.

    /cart/restore/

=cut

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

=head2 save

=over

=item Parameters: name

=back

Saves the current cart with the name specified.

    /cart/save/

=cut

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

=head2 update

=over

=item Parameters: quantity

=back

Updates the specified cart item qith the quantity given.

    /cart/update/

=cut

sub update : Local {
    my ($self, $c) = @_;

    if ($c->req->method eq 'POST') {
        if ($c->forward('validate')) {
            my $item = $c->user->cart->items({
                id => $c->req->param('id')
            })->first;

            if ($item) {
                $item->quantity($c->req->param('quantity'));
            };

            $c->res->redirect($c->uri_for('/cart/'));
        };
    } else {
        $c->res->redirect($c->uri_for('/cart/'));
    };

    return;
};

=head2 validate

Validates the current form parameters using the profile in profiles.yml that
matches the current action.

    if ($c->forward('validate')) {
    
    };

=cut

sub validate : Private {
    my ($self, $c) = @_;

    $self->{'validator'}->results->clear;

    my $results = $self->{'validator'}->check(
        $c->req,
        $self->{'profiles'}->{$c->action}
    );

    if ($results->success) {
        return $results;
    } else {
        $c->stash->{'errors'} = $results->messages($c->action);
    };

    return;
};

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
