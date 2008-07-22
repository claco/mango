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
__END__

=head1 NAME

Mango::Catalyst::Checkout::Plugins::Initialize - Mango checkout plugin to copy profile to order

=head1 SYNOPSIS

    my $checkout = Mango::Checkout->new({
        phase => 'CHECKOUT_PHASE_INITIALIZE'
    });
    $checkout->process;

=head1 DESCRIPTION

Mango::Catalyst::Checkout::Plugins::Initialize copies the current users
profile into the specified order.

=head1 METHODS

=head2 initialize

Copies the users profile into the current order.

=head2 register

Registers the current plugin.

=head1 SEE ALSO

L<Handel::Checkout::Plugin>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
