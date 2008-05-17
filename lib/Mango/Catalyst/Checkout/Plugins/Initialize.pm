package Mango::Catalyst::Checkout::Plugins::Initialize;
use strict;
use warnings;

BEGIN {
    use base 'Handel::Checkout::Plugin';
    use Handel::Constants qw(:checkout);
}

sub register {
    my ($self, $ctx) = @_;

    $ctx->add_handler(CHECKOUT_PHASE_INITIALIZE, \&initialize, 100);
};

sub initialize {
    my ($self, $ctx) = @_;
    my $order = $ctx->order;
    my $c = $ctx->stash->{'c'};
    my $profile = $c->user->profile;

    $order->billtofirstname($profile->first_name);
    $order->billtolastname($profile->last_name);

    $order->shiptosameasbillto(1);
    $order->shiptofirstname($profile->first_name);
    $order->shiptolastname($profile->last_name);

    return CHECKOUT_HANDLER_OK;
};

1;