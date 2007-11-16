# $Id$
package Mango::Catalyst::Controller::Users;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
    use Mango ();
    use Path::Class ();
    
    __PACKAGE__->form_directory(
        Path::Class::Dir->new(Mango->share, 'forms', 'admin', 'users')
    );
};

=head2 COMPONENT

=cut

sub COMPONENT {
    my $self = shift->NEXT::COMPONENT(@_);

    $self->register_namespace('users');

    return $self;
};

=head2 index

=cut

sub index : Chained PathPrefix Args(0) ActionClass('REST') {
    my ($self, $c) = @_;
    my $users = $c->model('Users')->search(undef, {
        page => $self->current_page,
        rows => $self->entries_per_page
    });
    my $pager = $users->pager;

    $c->stash->{'users'} = $users;
    $c->stash->{'pager'} = $pager;

    if ($self->wants_browser) {
        ## keep REST from going to _GET
        $c->detach;
    };

    return;
};

=head2 index_GET

=cut

sub index_GET : Private {
    my ($self, $c) = @_;
    my $users = $c->stash->{'users'};
    my $pager = $c->stash->{'pager'};

    my @users = map {
        {id => $_->id, username => $_->username}
    } $users->all;

    $self->entity({
        users => \@users
    }, $pager);

    return;
};

=head2 index_POST

=cut

sub index_POST : Private {
    my ($self, $c) = @_;

    if (my $user = $c->authenticate && $c->is_admin) {

    } else {
        $c->unauthorized;
    };

    return;
};

=head2 instance

=cut

sub instance : Chained PathPrefix CaptureArgs(1) {
    my ($self, $c, $id) = @_;

};

=head2 create

=cut

sub create : Local Template('admin/users/create') {
    my ($self, $c) = @_;
    my $form = $self->form;
    my @roles = $c->model('Roles')->search;

    $form->field('roles', options => [map {[$_->id, $_->name]} @roles]);

    $form->unique('username', sub {
        return !$c->model('Users')->search({
            username => $form->field('username')
        })->count;
    });

    if ($self->submitted && $self->validate->success) {
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
            $c->uri_for($self->action_for('index') , $user->id, 'edit/')
        );
    };
};

=head2 update

=cut

sub update : Chained('instance') PathPart Args(0) {
    my ($self, $c) = @_;
};

=head2 delete

=cut

sub delete : Chained('load') PathPart Args(0) Template('admin/users/delete') {
    my ($self, $c) = @_;

};




























#
#=head2 index_POST
#
#Creates a new user.
#
#=cut
#
#sub index_POST : Form('create') {
#    my ($self, $c) = @_;
#
#    if ($self->wants_browser) {
#        
#    } else {
#        if (my $user = $c->authenticate) {
#            warn $self->form;
#        } else {
#            $c->unauthorized;
#        };
#    };
#};

1;