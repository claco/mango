# $Id$
package Mango::User;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Object/;
};
__PACKAGE__->mk_group_accessors('column', qw/username password created/);

1;
