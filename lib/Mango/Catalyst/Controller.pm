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

sub current_page {
    my $c = shift->context;
    return $c->request->param('current_page') || 1;
};

sub entries_per_page {
    my $c = shift->context;
    return $c->request->param('entries_per_page') || 10;
};

1;