# $Id$
package Mango::Catalyst::Controller::Admin::Roles;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
    use Mango       ();
    use Path::Class ();

    __PACKAGE__->config(
        resource_name => 'mango/admin/roles',
        form_directory =>
          Path::Class::Dir->new( Mango->share, 'forms', 'admin', 'roles' )
    );
}

sub list : Chained('/') PathPrefix Args(0) Template('admin/roles/list') {
    my ( $self, $c ) = @_;
    my $page = $c->request->param('page') || 1;
    my $roles = $c->model('Roles')->search(
        undef,
        {
            page => $page,
            rows => 10
        }
    );

    $c->stash->{'roles'}       = $roles;
    $c->stash->{'pager'}       = $roles->pager;
    $c->stash->{'delete_form'} = $self->form('delete');

    return;
}

sub instance : Chained('/') PathPrefix CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    my $role = $c->model('Roles')->get_by_id($id);

    if ($role) {
        $c->stash->{'role'} = $role;
    } else {
        $c->response->status(404);
        $c->detach;
    }

    return;
}

sub create : Local Template('admin/roles/create') {
    my ( $self, $c ) = @_;
    my $form = $self->form;

    $form->unique(
        'name',
        sub {
            return !$c->model('Roles')
              ->search( { name => $form->field('name') } )->count;
        }
    );

    if ( $self->submitted && $self->validate->success ) {
        my $role = $c->model('Roles')->create(
            {
                name        => $form->field('name'),
                description => $form->field('description')
            }
        );

        $c->response->redirect(
            $c->uri_for( $self->action_for('edit'), [ $role->id ] ) . '/' );
    }

    return;
}

sub edit : Chained('instance') PathPart Args(0) Template('admin/roles/edit') {
    my ( $self, $c ) = @_;
    my $role = $c->stash->{'role'};
    my $form = $self->form;

    $form->values(
        {
            id          => $role->id,
            name        => $role->name,
            description => $role->description,
            created     => $role->created . '',
            updated     => $role->updated . ''
        }
    );

    if ( $self->submitted && $self->validate->success ) {
        $role->description( $form->field('description') );
        $role->update;

        $form->values( { updated => $role->updated . '' } );
    }

    return;
}

sub delete : Chained('instance') PathPart Args(0) Template('admin/roles/delete') {
    my ( $self, $c ) = @_;
    my $form = $self->form;
    my $role = $c->stash->{'role'};

    if ( $self->submitted && $self->validate->success ) {
        if ( $form->field('id') == $role->id ) {

            $role->destroy;

            $c->response->redirect(
                $c->uri_for( $self->action_for('list') ) . '/' );
        } else {
            $c->stash->{'errors'} = ['ID_MISTMATCH'];
        }
    }

    return;
}

1;
__END__

=head1 NAME

Mango::Catalyst::Controller::Admin::Roles - Catalyst controller for role admin

=head1 SYNOPSIS

    package MyApp::Controllers::Admin::Roles;
    use base qw/Mango::Catalyst::Controllers::Admin::Roles/;

=head1 DESCRIPTION

Mango::Catalyst::Controller::Admin::Roles is the controller
used to edit user roles.

=head1 ACTIONS

=head2 index : /admin/roles/

Displays the list of roles.

=head2 create : /admin/roles/create/

Creates a new role.

=head2 delete : /admin/roles/<id>/delete/

Deletes the specified role.

=head2 edit : /admin/roles/<id>/edit/

Updates the specified role.

=head2 load : /admin/role/<id>/

Loads a specific role.

=head1 SEE ALSO

L<Mango::Catalyst::Model::Roles>, L<Mango::Provider::Roles>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
