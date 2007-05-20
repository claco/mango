# $Id$
package Mango::Test::Catalyst::Response;
use strict;
use warnings;

BEGIN {
    use base qw/Class::Accessor::Grouped/;
    __PACKAGE__->mk_group_accessors('simple', qw/content_type body/);
};

1;