# $Id$
package Mango::Role;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Object/;
};
__PACKAGE__->mk_group_accessors('column', qw/name/);

1;
