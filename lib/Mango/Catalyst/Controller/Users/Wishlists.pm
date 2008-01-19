package Mango::Catalyst::Controller::Users::Wishlists;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
    use Handel::Constants qw/:cart/;
    use Mango ();
    use DateTime ();
    use Path::Class ();

    __PACKAGE__->config(
        resource_name  => 'mango/users/wishlists',
        form_directory => Path::Class::Dir->new(Mango->share, 'forms', 'users', 'wishlists')
    );
};

sub list : Chained('../instance') PathPart('wishlists') Args(0) Feed('Atom') Feed('RSS') Template('users/wishlists/list') {
    my ($self, $c) = @_;
    my $user = $c->stash->{'user'};
    my $profile = $c->model('Profiles')->search({user => $user})->first;
    my $wishlists = $c->model('Wishlists')->search({
        user => $user
    }, {
        page => $self->current_page,
        rows => $self->entries_per_page,
        order_by => 'updated desc'
    });

    if ($self->wants_feed) {
        $self->entity({
            title => $profile->full_name . '\'s Wishlists',
            link =>  $c->uri_for_resource('mango/users/wishlists', 'list', [$user->username]) . '/',
            modified => $wishlists->first ? $wishlists->first->updated : DateTime->now,
            entries => [
                map {{
                    id => $_->id,
                    author => $profile->full_name || $user->username,
                    title => $_->name,
                    link => $c->uri_for_resource('mango/users/wishlists', 'view', [$user->username, $_->id]) . '/',
                    content => $_->description || 'No description available.',
                    issued => $_->created,
                    modified => $_->updated
                }} $wishlists->all
            ]
        });
        $c->detach;
    } else {
        $c->stash->{'wishlists'} = $wishlists;
        $c->stash->{'pager'} = $wishlists->pager;
    };

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

sub view : Chained('instance') PathPart('') Args(0) Feed('Atom') Feed('RSS') Template('users/wishlists/view') {
    my ($self, $c) = @_;

    if ($self->wants_feed) {
        my $wishlist = $c->stash->{'wishlist'};
        my $user = $c->stash->{'user'};
        my $profile = $c->model('Profiles')->search({user => $user})->first;
        $self->entity({
            title => $profile->full_name . '\'s Wishlist: ' . $wishlist->name,
            link =>  $c->uri_for_resource('mango/users/wishlists', 'view', [$user->username, $wishlist->id]) . '/',
            modified => $wishlist->updated,
            entries => [
                map {{
                    id => $_->id,
                    author => $profile->full_name || $user->username,
                    title => $_->sku,
                    link => $c->uri_for_resource('mango/products', 'view', [$_->sku]) . '/',
                    content => '<p>Price: ' . $_->price->as_string('FMT_SYMBOL') . '</p><p>' . ($_->description || 'No description available.') . '</p>',
                    issued => $_->created,
                    modified => $_->updated
                }} $wishlist->items->all
            ]
        });
        $c->detach;
    };

    return;
};

1;
__END__
