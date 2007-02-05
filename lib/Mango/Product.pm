# $Id$
package Mango::Product;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Object/;

    __PACKAGE__->mk_group_accessors('column', qw/sku name description price/);
};

1;
__END__
