package Mango::Web::Controller::Admin;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::Controller/;
};

=head1 NAME

Mango::Web::Controller::Admin - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub begin : Private {
    my ($self, $c) = @_;

    if (!$c->check_user_roles('admin')) {
        $c->response->status(401);
        $c->stash->{'template'} = 'errors/401';
        $c->detach;
    };
};


=head2 index 

=cut

sub index : Private {
    my ($self, $c) = @_;
    $c->stash->{'template'} = 'admin/default';

};

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
