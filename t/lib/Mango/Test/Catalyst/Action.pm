# $Id$
package Mango::Test::Catalyst::Action;
use strict;
use warnings;

BEGIN {
    use base qw/Class::Accessor::Grouped/;
    __PACKAGE__->mk_group_accessors('simple', qw/attributes reverse/);
};

use overload (
    q{""} => sub {shift->{'reverse'}}
);

sub new {
    my ($class, $args) = @_;
    $args ||= {};
    $args->{'attributes'} ||= {};

    bless $args, $class;
};

1;