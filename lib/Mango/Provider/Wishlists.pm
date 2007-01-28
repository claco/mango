# $Id$
package Mango::Provider::Wishlists;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider::Carts/;
};
__PACKAGE__->result_class('Mango::Wishlist');

1;
__END__
