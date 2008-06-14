# $Id$
package Mango::Catalyst::Checkout::Plugins::Edit;
use strict;
use warnings;

BEGIN {
    use base 'Handel::Checkout::Plugin';
    use Handel::Constants qw(:checkout);
}

sub register {
    my ( $self, $ctx ) = @_;
warn "REG";

    $ctx->add_handler( 'EDIT', \&edit);

    return;
}

sub edit {
    warn "EDIT";
    my ( $self, $ctx ) = @_;
    my $order   = $ctx->order;
    my $c       = $ctx->stash->{'c'};
    my $profile = $c->user->profile;

    return CHECKOUT_HANDLER_OK;
}

1;
