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

    if ($self->wants_browser) {
        
    } else {
        $self->status_bad_request(
            $c, message => $c->localize('METHOD_NOT_SUPPORTED')
        );
    };
};

1;