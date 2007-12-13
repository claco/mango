package Mango::Catalyst::Controller::Logout;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
};

sub COMPONENT {
    my $class = shift;
    my $self = $class->NEXT::COMPONENT(@_);

    $self->register_as_resource('logout');

    return $self;
};

sub index : Template('logout/index') {
    my ($self, $c) = @_;

    if ($c->user_exists) {
        $c->logout;
    };
};

1;
