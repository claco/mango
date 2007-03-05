package Mango::Web::Controller::Wishlists;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::Controller/;
    use Handel::Constants qw/:cart/;
    use FormValidator::Simple 0.17;
    use YAML;
};

=head1 NAME

Mango::Web::Controller::Wishlists - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 COMPONENT

=cut

sub COMPONENT {
    my $self = shift->NEXT::COMPONENT(@_);

    $self->{'validator'} = FormValidator::Simple->new;
    $self->{'validator'}->set_messages(
        $_[0]->path_to('root', 'forms', 'wishlists', 'messages.yml')
    );

    $self->{'profiles'} = YAML::LoadFile($_[0]->path_to('root', 'forms', 'wishlists', 'profiles.yml'));

    return $self;
};

=head2 default 

Default action when browsing to /wishlists/. If no session exists, or the shopper
id isn't set, no cart will be loaded. This keeps non-shoppers like Google
and others from wasting sessions and cart records for no good reason.

=cut

sub default : Private {
    my ($self, $c) = @_;
    $c->stash->{'template'} = 'wishlists/default';

    if ($c->user_exists) {
        $c->stash->{'wishlists'} = $c->model('Wishlists')->user_wishlists($c->user->user->id);
    };

    return;
};

=head2 add

=over

=item Parameters: (See L<Handel::Cart/add>)

=back

Adds an item to the current cart during POST.

    /wishlists/add/

=cut

sub add : Local {
    my ($self, $c) = @_;
    
    if ($c->req->method eq 'POST') {
        my $cart = $c->forward('create');
        $cart->add($c->req->params);
    };

    $c->res->redirect($c->uri_for('/wishlists/'));
};

=head2 clear

Clears all items form the current shopping cart during POST.

    /wishlists/clear/

=cut

sub clear : Local {
    my ($self, $c) = @_;

    if ($c->req->method eq 'POST') {
        if (my $cart = $c->forward('load')) {
            $cart->clear;
        };
    };

    $c->res->redirect($c->uri_for('/wishlists/'));
};

=head2 create

Creats a new temporary shopping cart or returns the existing cart, creating a
new session shopper id if necessary.

    my $cart = $c->forward('create');

=cut

sub create : Private {
    my ($self, $c) = @_;

    if (!$c->session->{'shopper'}) {
        $c->session->{'shopper'} = $c->model('Cart')->storage->new_uuid;
    };

    if (my $cart = $c->forward('load')) {
        return $cart;
    } else {
        return $c->model('Cart')->create({
            shopper => $c->session->{'shopper'},
            type    => CART_TYPE_TEMP
        });
    };

    return;
};

=head2 delete

=over

=item Parameters: id

=back

Deletes an item from the current shopping cart during a POST.

    /wishlists/delete/

=cut

sub delete : Local {
    my ($self, $c) = @_;

    if ($c->req->method eq 'POST') {
        if ($c->forward('validate')) {
            if (my $cart = $c->forward('load')) {
                $cart->delete({
                    id => $c->req->params->{'id'}
                });

                $c->res->redirect($c->uri_for('/wishlists/'));
            };
        } else {
            $c->forward('default');
        };
    } else {
        $c->res->redirect($c->uri_for('/wishlists/'));
    };

    return;
};

=head2 destroy

=over

=item Parameters: id

=back

Deletes the specified saved cart and all of its items during a POST.

    /wishlists/destroy/

=cut

sub destroy : Local {
    my ($self, $c) = @_;

    if ($c->req->method eq 'POST') {
        if ($c->forward('validate')) {
            my $cart = $c->model('Cart')->search({
                id      => $c->req->params->{'id'},
                shopper => $c->session->{'shopper'},
                type    => CART_TYPE_SAVED
            })->first;

            if ($cart) {
                $cart->destroy;
            } else {
                warn "not cart";
            };

            $c->res->redirect($c->uri_for('/wishlists/list/'));
        } else {
            $c->forward('list');
        };
    } else {
        $c->res->redirect($c->uri_for('/wishlists/'));
    };

    return;
};

=head2 list

Displays a list of the current shoppers saved carts/wishlists.

    /wishlists/list/

=cut

sub list : Local {
    my ($self, $c) = @_;
    $c->stash->{'template'} = 'wishlists/list';

    if ($c->sessionid && $c->session->{'shopper'}) {
        my $carts = $c->model('Cart')->search({
            shopper => $c->session->{'shopper'},
            type    => CART_TYPE_SAVED
        });

        $c->stash->{'carts'} = $carts;
    };

    return;
};

=head2 load

Loads the shoppers current cart.

    my $cart = $c->forward('load');

=cut

sub load : Private {
    my ($self, $c) = @_;

    if ($c->sessionid && $c->session->{'shopper'}) {
        return $c->model('Cart')->search({
            shopper => $c->session->{'shopper'},
            type    => CART_TYPE_TEMP
        })->first;
    };

    return;
};

=head2 restore

=over

=item Parameters: id

=back

Restores a saved shopping cart into the shoppers current cart during a POST.

    /wishlists/restore/

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

                $c->res->redirect($c->uri_for('/wishlists/'));
            };
        } else {
            $c->forward('list');
        };
    } else {
        $c->res->redirect($c->uri_for('/wishlists/'));
    };

    return;
};

=head2 save

=over

=item Parameters: name

=back

Saves the current cart with the name specified.

    /wishlists/save/

=cut

sub save : Local {
    my ($self, $c) = @_;

    if ($c->req->method eq 'POST') {
        if ($c->forward('validate')) {
            if (my $cart = $c->forward('load')) {
                $cart->name($c->req->param('name') || 'My Cart');
                $cart->save;

                $c->res->redirect($c->uri_for('/wishlists/list/'));
            };
        } else {
            $c->forward('default');
        };
    } else {
        $c->res->redirect($c->uri_for('/wishlists/'));
    };

    return;
};

=head2 update

=over

=item Parameters: quantity

=back

Updates the specified cart item qith the quantity given.

    /wishlists/update/

=cut

sub update : Local {
    my ($self, $c) = @_;

    if ($c->req->method eq 'POST') {
        if ($c->forward('validate')) {
            if (my $cart = $c->forward('load')) {
                my $item = $cart->items({
                    id => $c->req->param('id')
                })->first;

                if ($item) {
                    $item->quantity($c->req->param('quantity'));
                };

                $c->res->redirect($c->uri_for('/wishlists/'));
            };
        } else {
            $c->forward('default');
        };
    } else {
        $c->res->redirect($c->uri_for('/wishlists/'));
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
