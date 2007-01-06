# $Id$
package Mango::User;
use strict;
use warnings;

BEGIN {
    use base qw/Class::Accessor::Grouped/;
};
__PACKAGE__->mk_group_accessors('simple', qw/result/);

sub AUTOLOAD {
    my $self = shift;
    return if (our $AUTOLOAD) =~ /::DESTROY$/;

    $AUTOLOAD =~ s/^.*:://;

    return $self->result->$AUTOLOAD(@_);
};

1;
