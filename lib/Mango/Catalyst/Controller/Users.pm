# $Id$
package Mango::Catalyst::Controller::Users;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
    use Mango       ();
    use Path::Class ();

    __PACKAGE__->config(
        resource_name => 'mango/users',
        form_directory =>
          Path::Class::Dir->new( Mango->share, 'forms', 'users' )
    );
}

sub instance : Chained('/') PathPrefix CaptureArgs(1) {
    my ( $self, $c, $username ) = @_;
    my $user = $c->model('Users')->search( { username => $username } )->first;

    if ( defined $user ) {
        $c->stash->{'user'} = $user;

        my $profile =
          $c->model('Profiles')->search( { user => $user } )->first;

        $c->stash->{'profile'} = $profile;
    } else {
        $c->response->status(404);
        $c->detach;
    }

    return;
}

sub view : Chained('instance') PathPart('') Args(0) Template('users/view') {
    my ( $self, $c ) = @_;

    return;
}

sub create : Local Template('users/create') {
    my ( $self, $c ) = @_;
    my $form = $self->form;

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

        $c->authenticate(
            {
                username => $user->username,
                password => $user->password
            }
        );

        $c->response->redirect(
            $c->uri_for_resource( 'mango/settings', 'profile' ) . '/' );
    }

    return;
}

1;
__END__

=head1 NAME

Mango::Catalyst::Controller::Users - Catalyst controller for displaying users

=head1 SYNOPSIS

    package MyApp::Controller::Users;
    use base 'Mango::Catalyst::Controller::Users';

=head1 DESCRIPTION

Mango::Catalyst::Controller::Users provides the web interface for
display users and their information.

=head1 ACTIONS

=head2 create : /users/create/

Creates, or 'signs up' a new user.

=head2 instance : /users/<username>/

Loads the specified user.

=head2 view : /users/<username>/

Displays information for the specified user.

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/

