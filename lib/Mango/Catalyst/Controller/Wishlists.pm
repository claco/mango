package Mango::Catalyst::Controller::Wishlists;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
    use Handel::Constants qw/:cart/;
    use Mango ();
    use Path::Class::Dir ();

    __PACKAGE__->config(
        resource_name  => 'wishlists',
        form_directory => Path::Class::Dir->new(Mango->share, 'forms', 'wishlists')
    );
};

sub begin : Private {
    my ($self, $c) = @_;

    if (!$c->user_exists) {
        $c->response->status(401);
        $c->stash->{'template'} = 'errors/401';
        $c->detach;
    };
};

sub index : Chained('/') PathPrefix Args(0) Template('wishlists/index') {
    my ($self, $c) = @_;
    my $wishlists = $c->model('wishlists')->search({
        user => $c->user->id
    }, {
        page => $self->current_page,
        rows => $self->entries_per_page
    });
    my $pager = $wishlists->pager;

    $c->stash->{'wishlists'} = $wishlists;
    $c->stash->{'pager'} = $pager;

    return;
};

sub instance : Chained('/') PathPrefix CaptureArgs(1) {
    my ($self, $c, $id) = @_;
    my $wishlist = $c->model('Wishlists')->search({
        user => $c->user->id,
        id   => $id
    })->first;

    if (defined $wishlist) {
        $c->stash->{'wishlist'} = $wishlist;
    } else {
        $c->response->status(404);
        $c->detach;
    };
};

sub view : Chained('instance') PathPart('') Args(0) Template('wishlists/view') {
    my ($self, $c) = @_;

};

sub edit : Chained('instance') PathPart Args(0) Template('wishlists/edit') {
    my ($self, $c) = @_;
    my $wishlist = $c->stash->{'wishlist'};
#    my $form = $self->form;

#    $form->values({
#        id          => $role->id,
#        name        => $role->name,
#        description => $role->description,
#        created     => $role->created . '',
#        updated     => $role->updated . ''
#    });

#    if ($self->submitted && $self->validate->success) {
#        $role->description($form->field('description'));
#        $role->update;
#
#        $form->values({
#            updated     => $role->updated . ''
#        });
#    };
};

1;
__END__
