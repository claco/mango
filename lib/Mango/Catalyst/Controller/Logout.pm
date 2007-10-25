package Mango::Catalyst::Controller::Logout;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::Controller/;
};

sub COMPONENT {
    my $class = shift;
    my $self = $class->NEXT::COMPONENT(@_);
    $_[0]->config->{'mango'}->{'controllers'}->{'logout'} = $class;

    return $self;
};

sub index : Template('logout/index') {
    my ($self, $c) = @_;

    if ($c->user_exists) {
        $c->logout;
    };
};

1;
