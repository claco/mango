# $Id$
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

=head1 NAME

Mango::Catalyst::Controller::Admin - Catalyst controller for admin tasks

=head1 SYNOPSIS

    package MyApp::Controllers::Admin;
    use base qw/Mango::Catalyst::Controllers::Admin/;

=head1 DESCRIPTION

Mango::Catalyst::Controller::Admin is the controller used for various admin
related tasks.

=head1 ACTIONS

=head2 auto

Ensures the current user is in the admin role, otherwise returning an http
401 status code.

=head2 index : /admin/

The generic admin status page.

=head1 SEE ALSO

L<Mango::Catalyst::Controller::Admin::Users>,
L<Mango::Catalyst::Controller::Admin::Roles>,
L<Mango::Catalyst::Controller::Admin::Products>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
