# $Id: User.pm 1718 2007-02-05 03:00:43Z claco $
package Mango::User;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Object/;

    __PACKAGE__->mk_group_accessors('column', qw/username password/);
};

1;
