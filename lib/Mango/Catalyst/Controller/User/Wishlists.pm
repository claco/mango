package Mango::Catalyst::Controller::Users::Wishlists;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
    use Handel::Constants qw/:cart/;
    use Mango ();
    use Path::Class ();

    __PACKAGE__->config(
        resource_name  => 'users/wishlists',
        form_directory => Path::Class::Dir->new(Mango->share, 'forms', 'users', 'wishlists')
    );
};

sub index : Template('user/wishlists/index') {
    my ($self, $c) = @_;

    if ($c->user_exists) {
        $c->stash->{'wishlists'} = $c->model('Wishlists')->search({
            user => $c->user->get_object
        });
    };

    return;
};

sub default : Template('user/wishlists/details') {
    my ($self, $c, @args) = @_;
    my $id = $args[-1];

    $c->forward('load', [$id]);
};

sub load : Chained('/') PathPrefix CaptureArgs(1) {
    my ($self, $c, $id) = @_;
    my $wishlist = $c->model('Wishlists')->get_by_id($id);

    if ($wishlist) {
        $c->stash->{'wishlist'} = $wishlist;
    } else {
        $c->response->status(404);
        $c->detach;
    };
};

sub details : Chained('load') PathPart Args(0) Template('user/wishlists/details') {
    my ($self, $c) = @_;
};

1;
__END__
