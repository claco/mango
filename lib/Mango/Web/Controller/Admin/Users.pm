package Mango::Web::Controller::Admin::Users;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Web::Base::Form/;
    use FormValidator::Simple::Constants;
    use Set::Scalar ();
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
    $c->stash->{'template'} = 'admin/users/default';

    my $page = $c->request->param('page') || 1;
    my $users = $c->model('Users')->search(undef, {
        page => $page
    });

    $c->stash->{'users'} = $users;
    $c->stash->{'pager'} = $users->pager;
};

sub load : PathPart('admin/users') Chained('/') CaptureArgs(1) {
    my ($self, $c, $id) = @_;
    my $user = $c->model('Users')->get_by_id($id);
    my $profile = $c->model('Profiles')->get_by_user($user)->first;

    $c->stash->{'user'} = $user;
    $c->stash->{'profile'} = $profile;
};

sub create : Local {
    my ($self, $c) = @_;
    my $form = $c->forward('form');
    my @roles = $c->model('Roles')->search;

    $form->field('roles', options => [map {[$_->id, $_->name]} @roles]);

    ## I love being evil. I'll make plugins eventually, but I don't want
    ## the module clutter at the moment
    local *FormValidator::Simple::Validator::USER_UNIQUE = sub {
        return $c->model('Users')->search({
            username => $form->field('username')
        })->count ? FALSE : TRUE;
    };

    if ($c->forward('submitted') && $c->forward('validate')) {
        my $user = $c->model('Users')->create({
            username => $form->field('username'),
            password => $form->field('password')
        });

        my $profile = $c->model('Profiles')->create({
            user_id => $user->id,
            first_name => $form->field('first_name'),
            last_name  => $form->field('last_name')
        });

        foreach my $role ($form->field('roles')) {
            $c->model('Roles')->add_user($role, $user);
        };

        $c->response->redirect(
            $c->uri_for('/admin/users', $user->id, 'edit')
        );
    };
};

sub edit : PathPart('edit') Chained('load') Args(0) {
    my ($self, $c) = @_;
    my $user    = $c->stash->{'user'};
    my $profile = $c->stash->{'profile'};
    my @membership = $c->model('Roles')->get_by_user($user);
    my @roles = $c->model('Roles')->search;
    my $form    = $c->forward('form');

    $form->field('roles', options => [map {[$_->id, $_->name]} @roles]);
    $form->values({
        id               => $user->id,
        username         => $user->username,
        password         => $user->password,
        confirm_password => $user->password,
        created          => $user->created . '',
        first_name       => $profile->first_name,
        last_name        => $profile->last_name,
        
        ## for some reason FB is wonky about no selected multiples compared to values
        ## yet it get's empty fields correct against non multiple values
        roles            => $c->request->method eq 'GET' ? [map {$_->id} @membership] : []
    });

    $c->stash->{'roles'} = $c->model('Roles')->search;
    $c->stash->{'user_roles'} = $c->model('Roles')->get_by_user($user);

    if ($c->forward('submitted') && $c->forward('validate')) {
        my $current_roles = Set::Scalar->new(map {$_->id} @membership);
        my $selected_roles = Set::Scalar->new($form->field('roles'));
        
        warn "SELECTED: ", $selected_roles->size;
        warn "ROLES: ", $form->field('roles');
        
        my $deleted_roles = $current_roles - $selected_roles;
        my $added_roles = $selected_roles - $current_roles;

warn "DELETED: ", $deleted_roles->members;
warn "ADDED: ", $added_roles->members;

        $user->password($form->field('password'));
        $user->update;

        $profile->first_name($form->field('first_name'));
        $profile->last_name($form->field('last_name'));
        $profile->update;

        if ($deleted_roles->size) {
            map {
                $c->model('Roles')->remove_users($_, $user)
            } $deleted_roles->members;
        };

        if ($added_roles->size) {
            map {
                $c->model('Roles')->add_users($_, $user)
            } $added_roles->members;
        };
    };
};

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
