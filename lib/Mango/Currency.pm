package Mango::Currency;
use Moose;

extends 'Handel::Currency';

1;
__END__

=head1 NAME

Mango::Currency - Module for currency formatting and conversion

=head1 SYNOPSIS

    print $product->price->convert('CAD');

=head1 DESCRIPTION

Mango::Currency is a module for currency formatting and conversion.
It is returned for all inflated price columns in Mango.

Mango::Currency is a subclass of Handel::Currency, which is in turn a subclass
of Data::Currency.

=head1 SEE ALSO

L<Handel::Currency>, L<Data::Currency>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
