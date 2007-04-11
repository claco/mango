# $Id: Wishlists.pm 1683 2007-01-28 02:58:37Z claco $
package Mango::Provider::Wishlists;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider::Carts/;
};
__PACKAGE__->result_class('Mango::Wishlist');

1;
__END__
