package Mango::Catalyst::Controller::Admin;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;

    __PACKAGE__->config(
        resource_name  => 'mango/admin'
    );
};

sub auto : Private {
    my ($self, $c) = @_;

    if (!$c->check_user_roles('admin')) {
        $c->response->status(401);
        $c->stash->{'template'} = 'errors/401';
        $c->detach;
    };

    return 1;
};

sub index : Template('admin/index') {
    my ($self, $c) = @_;

};

1;
__END__
