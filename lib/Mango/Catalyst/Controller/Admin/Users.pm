package Mango::Catalyst::Controller::Admin::Users;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller::Form/;
    use Set::Scalar ();
    use Mango ();
    use Path::Class ();
    
    __PACKAGE__->form_directory(
        Path::Class::Dir->new(Mango->share, 'forms', 'admin', 'users')
    );
};

sub _parse_PathPrefix_attr {
    my ($self, $c, $name, $value) = @_;

    return PathPart => $self->path_prefix;
};

sub index : Template('admin/users/index') {
    my ($self, $c) = @_;
    my $page = $c->request->param('page') || 1;
    my $users = $c->model('Users')->search(undef, {
        page => $page,
        rows => 10
    });

    $c->stash->{'users'} = $users;
    $c->stash->{'pager'} = $users->pager;
    $c->stash->{'delete_form'} = $self->form('delete');
};

sub load : Chained('/') PathPrefix CaptureArgs(1) {
    my ($self, $c, $id) = @_;
    my $user = $c->model('Users')->get_by_id($id);

    if ($user) {
        my $profile = $c->model('Profiles')->search({
            user => $user
        })->first;

        $c->stash->{'user'} = $user;
        $c->stash->{'profile'} = $profile;
    } else {
        $c->response->status(404);
        $c->detach;
    };
};

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
            $c->uri_for('/', $self->path_prefix, $user->id, 'edit/')
        );
    };
};

sub edit : Chained('load') PathPart Args(0) Template('admin/users/edit') {
    my ($self, $c) = @_;
    my $user = $c->stash->{'user'};
    my $profile = $c->stash->{'profile'};
    my @membership = $c->model('Roles')->search({
        user => $user
    });
    my @roles = $c->model('Roles')->search;
    my $form = $self->form;

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
    $c->stash->{'user_roles'} = $c->model('Roles')->search({
        user => $user
    });

    if ($self->submitted && $self->validate->success) {
        my $current_roles = Set::Scalar->new(map {$_->id} @membership);
        my $selected_roles = Set::Scalar->new($form->field('roles'));
        my $deleted_roles = $current_roles - $selected_roles;
        my $added_roles = $selected_roles - $current_roles;

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

sub delete : Chained('load') PathPart Args(0) Template('admin/users/delete') {
    my ($self, $c) = @_;
    my $form = $self->form;
    my $user = $c->stash->{'user'};

    if ($self->submitted && $self->validate->success) {
        if ($form->field('id') == $user->id) {

            ## remove from all roles
            map {
                $_->remove_user($user);
            } $c->model('Roles')->search({
                user => $user
            });

            ## delete profile
            $c->model('Profiles')->delete({
                user => $user
            });

            ## delete wishlists
            $c->model('Wishlists')->delete({
                user => $user
            });

            ## delete carts
            $c->model('Carts')->delete({
                user => $user
            });

            ## delete user
            $user->destroy;

            $c->response->redirect(
                $c->uri_for('/', $self->path_prefix . '/')
            );
        } else {
            $c->stash->{'errors'} = ['ID_MISTMATCH'];
        };
    };
};

1;
__END__

=head1 NAME

Mango::Tag - Module representing a [folksonomy] tag

=head1 SYNOPSIS

    my $tags = $product->tags;
    
    while (my $tag = %tags->next) {
        print $tag->name;
    };

=head1 DESCRIPTION

Mango::Tag represents a tag assigned to products.

=head1 METHODS

=head2 count

Returns the number of instances this tag.

B<This is not currently implemented and always returns 0>.

=head2 created

Returns the date and time in UTC the tag was created as a DateTime
object.

    print $user->created;

=head2 destroy

B<This is not currently implemented>.

=head2 id

Returns the id of the current tag.

    print $tag->id;

=head2 name

=over

=item Arguments: $name

=back

Gets/sets the name of the current tag.

    print $tag->name;

=head2 updated

Returns the date and time in UTC the tag was last updated as a DateTime
object.

    print $user->updated;

=head1 SEE ALSO

L<Mango::Object>, L<Mango::Product>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
