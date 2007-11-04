package Mango::Catalyst::Controller;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller::REST Mango::Catalyst::Controller::Form/;
};

sub _parse_PathPrefix_attr {
    my ($self, $c, $name, $value) = @_;

    return PathPart => $self->path_prefix;
};

1;