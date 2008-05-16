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

    warn "INIT FROM MANGO CATALYST PLUGIN";

    warn $ctx->stash->{'c'}->user->profile->first_name;

    return CHECKOUT_HANDLER_OK;
};

1;