package Mango::Catalyst::Controller::Logout;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;

    __PACKAGE__->config(
        resource_name  => 'logout'
    );
};

sub index : Template('logout/index') {
    my ($self, $c) = @_;

    if ($c->user_exists) {
        $c->logout;
    };
};

1;
