package Mango::Catalyst::Controller::Logout;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::Controller/;
};

sub index : Template('logout/index') {
    my ($self, $c) = @_;

    if ($c->user_exists) {
        $c->logout;
    };
};

1;
