# $Id$
package Mango::Form::Results;
use strict;
use warnings;

BEGIN {
    use base qw/Class::Accessor::Grouped/;

    __PACKAGE__->mk_group_accessors('simple', qw/_results errors/);
};

sub new {
    my ($class, $args) = @_;

    return bless $args || {}, $class;
};

sub success {
    return shift->_results->success;
};

1;
__END__