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

sub register_namespace {
    my ($self, $namespace) = @_;
    my $config = $self->context->config;

    $config->{'mango'}->{'controllers'}->{$namespace} = ref $self || $self;
};

sub current_page {
    my $c = shift->context;
    return $c->request->param('current_page') || 1;
};

sub entries_per_page {
    my $c = shift->context;
    return $c->request->param('entries_per_page') || 10;
};

## this sucks. REST exposes validate via Params::Validate :all and I have an
## ISA ordering issue with that
sub validate {
    my $self = shift;

    if ($self->wants_browser) {
        return Mango::Catalyst::Controller::Form::validate($self, @_);
    } else {
        return $self->SUPER::validate(@_);
    };
};

1;
