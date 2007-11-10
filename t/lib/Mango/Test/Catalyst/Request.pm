# $Id$
package Mango::Test::Catalyst::Request;
use strict;
use warnings;

BEGIN {
    use base qw/Class::Accessor::Grouped/;
    __PACKAGE__->mk_group_accessors('simple', qw/action base content_type uri/);
};

sub new {
    my $class = shift;

    bless shift || {}, $class;
};

sub header {
    return shift->{$_[0]};
};

sub param {
    return shift->{$_[0]};
};

sub method {
    return 'GET';
};

1;