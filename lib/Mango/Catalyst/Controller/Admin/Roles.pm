package Mango::Catalyst::Controller::Admin::Roles;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller::Form/;
};

sub _parse_PathPrefix_attr {
    my ($self, $c, $name, $value) = @_;

    return PathPart => $self->path_prefix;
};

sub index : Private {
    my ($self, $c) = @_;
    my $page = $c->request->param('page') || 1;
    my $roles = $c->model('Roles')->search(undef, {
        page => $page,
        rows => 10
    });

    $c->stash->{'roles'} = $roles;
    $c->stash->{'pager'} = $roles->pager;
};

sub load : Chained('/') PathPrefix CaptureArgs(1) {
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
    my $form = $self->form;

    $form->unique('name', sub {
        return !$c->model('Roles')->search({
            name => $form->field('name')
        })->count;
    });

    if ($self->submitted && $self->validate->success) {
        my $role = $c->model('Roles')->create({
            name => $form->field('name'),
            description => $form->field('description')
        });

        $c->response->redirect(
            $c->uri_for('/', $self->path_prefix, $role->id, 'edit/')
        );
    };
};

sub edit : Chained('load') PathPart Args(0) {
    my ($self, $c) = @_;
    my $role = $c->stash->{'role'};
    my $form = $self->form;

    $form->values({
        id          => $role->id,
        name        => $role->name,
        description => $role->description,
        created     => $role->created . ''
    });

    if ($self->submitted && $self->validate->success) {
        $role->description($form->field('description'));
        $role->update;
    };
};

1;
__END__
