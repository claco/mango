# $Id$
package Mango::Catalyst::Controller::Users;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
};

sub index : ActionClass('REST') Template('users/index') {
    my ($self, $c) = @_;

};

sub index_GET : Private {
    my ($self, $c) = @_;

};

sub index_POST : Private {
    my ($self, $c) = @_;

    if ($c->is_admin) {
        
    } else {
        $c->unauthorized;
    };
};

1;