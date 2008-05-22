# $Id$
package Mango::Checkout::Stash;
use strict;
use warnings;

BEGIN {
    use base 'Handel::Checkout::Stash';
}

1;
__END__

=head1 NAME

Mango::Checkout::Stash - Mango class to pass data between plugins

=head1 SYNOPSIS

    my $checkout = Mango::Checkout->new;
    $checkout->stash->{'DISABLE_FOO'} = 1;
    $checkout->process;

=head1 DESCRIPTION

Mango::Checkout::Stash holds and data plugins need to store and pass around
to each other between calls to process.

=head1 SEE ALSO

L<Handel::Checkout::Stash>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
