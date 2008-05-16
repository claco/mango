# $Id$
package Mango::Checkout;
use strict;
use warnings;

BEGIN {
    use base qw/Handel::Checkout/;
}

__PACKAGE__->stash_class('Mango::Checkout::Stash');

1;
__END__

=head1 NAME

Mango::Checkout - Mango class to handle checkout/order processing

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
