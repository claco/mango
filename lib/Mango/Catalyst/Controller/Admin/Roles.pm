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
    $c->stash->{'delete_form'} = Clone::clone($self->form('delete'));
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

sub delete : Chained('load') PathPart Args(0) {
    my ($self, $c) = @_;
    my $form = $self->form;
    my $role = $c->stash->{'role'};

    if ($self->submitted && $self->validate->success) {
        if ($form->field('id') == $role->id) {

            $role->destroy;

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
