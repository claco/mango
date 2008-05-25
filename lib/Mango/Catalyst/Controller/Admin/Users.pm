# $Id$
package Mango::Catalyst::Controller::Admin::Users;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
    use Set::Scalar ();
    use Mango       ();
    use Path::Class ();

    __PACKAGE__->config(
        resource_name => 'mango/admin/users',
        form_directory =>
          Path::Class::Dir->new( Mango->share, 'forms', 'admin', 'users' )
    );
}

sub list : Chained('/') PathPrefix Args(0) Template('admin/users/index') {
    my ( $self, $c ) = @_;
    my $page = $c->request->param('page') || 1;
    my $users = $c->model('Users')->search(
        undef,
        {
            page => $page,
            rows => 10
        }
    );

    $c->stash->{'users'}       = $users;
    $c->stash->{'pager'}       = $users->pager;
    $c->stash->{'delete_form'} = $self->form('delete');

    return;
}

sub instance : Chained('/') PathPrefix CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    my $user = $c->model('Users')->get_by_id($id);

    if ($user) {
        my $profile =
          $c->model('Profiles')->search( { user => $user } )->first;

        $c->stash->{'user'}    = $user;
        $c->stash->{'profile'} = $profile;
    } else {
        $c->response->status(404);
        $c->detach;
    }

    return;
}

sub create : Local Template('admin/users/create') {
    my ( $self, $c ) = @_;
    my $form  = $self->form;
    my @roles = $c->model('Roles')->search;

    $form->field( 'roles',
        options => [ map { [ $_->id, $_->name ] } @roles ] );

    $form->unique(
        'username',
        sub {
            return !$c->model('Users')
              ->search( { username => $form->field('username') } )->count;
        }
    );

    if ( $self->submitted && $self->validate->success ) {
        my $user = $c->model('Users')->create(
            {
                username => $form->field('username'),
                password => $form->field('password')
            }
        );

        my $profile = $c->model('Profiles')->create(
            {
                user_id    => $user->id,
                first_name => $form->field('first_name'),
                last_name  => $form->field('last_name')
            }
        );

        foreach my $role ( $form->field('roles') ) {
            $c->model('Roles')->add_user( $role, $user );
        }

        $c->res->redirect(
            $c->uri_for( $self->action_for('edit'), [ $user->id ] ) . '/' );
    }

    return;
}

sub edit : Chained('instance') PathPart Args(0) Template('admin/users/edit') {
    my ( $self, $c ) = @_;
    my $user       = $c->stash->{'user'};
    my $profile    = $c->stash->{'profile'};
    my @membership = $c->model('Roles')->search( { user => $user } );
    my @roles      = $c->model('Roles')->search;
    my $form       = $self->form;

    $form->field( 'roles',
        options => [ map { [ $_->id, $_->description ] } @roles ] );

    $form->values(
        {
            id               => $user->id,
            username         => $user->username,
            password         => $user->password,
            confirm_password => $user->password,
            created          => $user->created . '',
            updated          => $user->updated . '',
            first_name       => $profile->first_name,
            last_name        => $profile->last_name,

            ## for some reason FB is wonky about no selected multiples compared to values
            ## yet it get's empty fields correct against non multiple values
            roles => $c->request->method eq 'GET'
            ? [ map { $_->id } @membership ]
            : []
        }
    );

    $c->stash->{'roles'} = $c->model('Roles')->search;
    $c->stash->{'user_roles'} =
      $c->model('Roles')->search( { user => $user } );

    if ( $self->submitted && $self->validate->success ) {
        my $current_roles  = Set::Scalar->new( map { $_->id } @membership );
        my $selected_roles = Set::Scalar->new( $form->field('roles') );
        my $deleted_roles  = $current_roles - $selected_roles;
        my $added_roles    = $selected_roles - $current_roles;

        $user->password( $form->field('password') );
        $user->update;

        $form->values( { updated => $user->updated . '' } );

        $profile->first_name( $form->field('first_name') );
        $profile->last_name( $form->field('last_name') );
        $profile->update;

        if ( $deleted_roles->size ) {
            foreach my $role ( $deleted_roles->members ) {
                $c->model('Roles')->remove_users( $role, $user );
            }
        }

        if ( $added_roles->size ) {
            foreach my $role ( $added_roles->members ) {
                $c->model('Roles')->add_users( $role, $user );
            }
        }
    }

    return;
}

sub delete : Chained('instance') PathPart Args(0) Template('admin/users/delete') {
    my ( $self, $c ) = @_;
    my $form = $self->form;
    my $user = $c->stash->{'user'};

    if ( $self->submitted && $self->validate->success ) {
        if ( $form->field('id') == $user->id ) {

            ## remove from all roles
            foreach
              my $role ( $c->model('Roles')->search( { user => $user } ) )
            {
                $role->remove_user($user);
            }

            ## delete profile
            $c->model('Profiles')->delete( { user => $user } );

            ## delete wishlists
            $c->model('Wishlists')->delete( { user => $user } );

            ## delete carts
            $c->model('Carts')->delete( { user => $user } );

            ## delete user
            $user->destroy;

            $c->res->redirect(
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

Mango::Catalyst::Controller::Admin::Users - Catalyst controller for user admin

=head1 SYNOPSIS

    package MyApp::Controllers::Admin::Users;
    use base qw/Mango::Catalyst::Controllers::Admin::Users/;

=head1 DESCRIPTION

Mango::Catalyst::Controller::Admin::Users is the controller
used to edit user accounts.

=head1 ACTIONS

=head2 index : /admin/users/

Displays the list of users.

=head2 create : /admin/users/create/

Creates a new user.

=head2 delete : /admin/users/<id>/delete/

Deletes the specified user.

=head2 edit : /admin/users/<id>/edit/

Updates the specified user.

=head2 load : /admin/users/<id>/

Loads a specific user.

=head1 SEE ALSO

L<Mango::Catalyst::Model::Users>, L<Mango::Provider::Users>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
