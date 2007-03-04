package Mango::Web::Controller::Admin::Roles;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Web::Base::Form/;
    use FormValidator::Simple::Constants;
};

=head1 NAME

Mango::Web::Controller::Admin::Users - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
    my ($self, $c) = @_;
    $c->stash->{'template'} = 'admin/roles/default';

    my $page = $c->request->param('page') || 1;
    my $roles = $c->model('Roles')->search(undef, {
        page => $page,
        rows => 10
    });

    $c->stash->{'roles'} = $roles;
    $c->stash->{'pager'} = $roles->pager;
};

sub load : PathPart('admin/roles') Chained('/') CaptureArgs(1) {
    my ($self, $c, $id) = @_;
    my $role = $c->model('Roles')->get_by_id($id);

    if ($role) {
        $c->stash->{'role'} = $role;
    } else {
        $c->response->status(404);
        $c->detach;
    };
};

sub create : Local {
    my ($self, $c) = @_;
    my $form = $c->forward('form');

    ## I love being evil. I'll make plugins eventually, but I don't want
    ## the module clutter at the moment
    local *FormValidator::Simple::Validator::ROLE_UNIQUE = sub {
        return $c->model('Roles')->search({
            name => $form->field('name')
        })->count ? FALSE : TRUE;
    };

    if ($c->forward('submitted') && $c->forward('validate')) {
        my $role = $c->model('Roles')->create({
            name => $form->field('name'),
            description => $form->field('description')
        });

        $c->response->redirect(
            $c->uri_for('/admin/roles', $role->id, 'edit')
        );
    };
};

sub edit : PathPart('edit') Chained('load') Args(0) {
    my ($self, $c) = @_;
    my $role = $c->stash->{'role'};
    my $form = $c->forward('form');

    $form->values({
        id          => $role->id,
        name        => $role->name,
        description => $role->description,
        created     => $role->created . ''
    });

    if ($c->forward('submitted') && $c->forward('validate')) {
        $role->description($form->field('description'));
        $role->update;
    };
};

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
