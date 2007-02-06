# $Id$
package Mango::Attribute;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Object/;

    __PACKAGE__->mk_group_accessors('column', qw/name value/);
};

1;
__END__
