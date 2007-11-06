# $Id$
package Mango::Catalyst::Controller::Users;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
};

sub COMPONENT {
    my $class = shift;
    my $self = $class->NEXT::COMPONENT(@_);
    $_[0]->config->{'mango'}->{'controllers'}->{'users'} = $class;

    return $self;
};

sub index : ActionClass('REST') Template('users/index') {
    my ($self, $c) = @_;

};

=head2 index_GET

When serving content to a web browser, this returns the search form
r search results. When serving content to a RESTful client, this
returns a collection of user data.

=cut

sub index_GET : Private {
    my ($self, $c) = @_;
    my $users = $c->model('Users')->search(undef, {
        page => $self->page,
        rows => $self->rows
    });
    my $pager = $users->pager;

    if ($self->wants_browser) {
        $c->stash->{'users'} = $users;
        $c->stash->{'pager'} = $pager;
    } else {
        my @users = map {
            {id => $_->id, username => $_->username}
        } $users->all;

        $self->entity({
            users => \@users
        });
    };
};

=head2 index_POST

Creates a new user.

=cut

sub index_POST : Private {
    my ($self, $c) = @_;

    if ($c->is_admin) {

    } else {
        $c->unauthorized;
    };
};

1;