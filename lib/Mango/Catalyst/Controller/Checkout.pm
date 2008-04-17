# $Id$
package Mango::Catalyst::Controller::Checkout;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;

    __PACKAGE__->config(
        resource_name => 'mango/checkout',
        form_directory =>
          Path::Class::Dir->new( Mango->share, 'forms', 'checkout' )
    );
}

sub index : Template('cart/index') {
    my ( $self, $c ) = @_;

    return;
}

sub instance : Chained('/') PathPrefix Args(1) {
    my ( $self, $c, $state ) = @_;

    carp $state;

    return;
}

1;
__END__

=head1 NAME

Mango::Catalyst::Controller::Checkout - Catalyst controller for checkout

=head1 SYNOPSIS

    package MyApp::Controller::Checkout;
    use base 'Mango::Catalyst::Controller::Checkout';

=head1 DESCRIPTION

Mango::Catalyst::Controller::Checkout provides the web interface for the
checkout process.

=head1 ACTIONS

=head2 instance : /checkout/<state>

Runs the specified checkout state.

=head1 SEE ALSO

L<Mango::Checkout>, L<Handel::Checkout>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
