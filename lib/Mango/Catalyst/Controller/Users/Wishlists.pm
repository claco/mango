package Mango::Catalyst::Controller::Users::Wishlists;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
    use Handel::Constants qw/:cart/;
    use Mango ();
    use Path::Class ();

    __PACKAGE__->config(
        resource_name  => 'mango/users/wishlists',
        form_directory => Path::Class::Dir->new(Mango->share, 'forms', 'users', 'wishlists')
    );
};

sub list : Chained('../instance') PathPart('wishlists') Args(0) Template('users/wishlists/list') {
    my ($self, $c) = @_;
    my $user = $c->stash->{'user'};
    my $wishlists = $c->model('Wishlists')->search({
        user => $user
    }, {
        page => $self->current_page,
        rows => $self->entries_per_page
    });
    my $pager = $wishlists->pager;

    $c->stash->{'wishlists'} = $wishlists;
    $c->stash->{'pager'} = $pager;

    return;
};

sub instance : Chained('../instance') PathPart('wishlists') CaptureArgs(1) {
    my ($self, $c, $id) = @_;
    my $user = $c->stash->{'user'};
    my $wishlist = $c->model('Wishlists')->search({
        user => $user,
        id   => $id
    })->first;

    if (defined $wishlist) {
        $c->stash->{'wishlist'} = $wishlist;
    } else {
        $c->response->status(404);
        $c->detach;
    };
};

sub view : Chained('instance') PathPart('') Args(0) Template('users/wishlists/view') {
    my ($self, $c) = @_;

    return;
};

1;
__END__
