# $Id$
package Mango::Currency;
use strict;
use warnings;

BEGIN {
    use base qw/Handel::Currency/;
};

1;
__END__

=head1 NAME

Mango::Currency - Currency class for Mango

=head1 SYNOPSIS

    print $product->price->convert('CAD');

=head1 DESCRIPTION

Mango::Currency is returned for all inflated price columns in Mango. It is
a subclass if Handel::Currency, which is a subclass of Data::Currency.

=head1 SEE ALSO

L<Handel::Currency>, L<Data::Currency>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
