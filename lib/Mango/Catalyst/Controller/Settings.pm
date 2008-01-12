package Mango::Catalyst::Controller::Settings;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
    use Mango ();
    use Path::Class::Dir ();

    __PACKAGE__->config(
        resource_name  => 'mango/settings',
        form_directory => Path::Class::Dir->new(Mango->share, 'forms', 'settings')
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

sub profile : Local Template('settings/profile') {
    my ($self, $c) = @_;
    my $form = $self->form;
    my $user = $c->user;
    my $profile = $user->profile;

    $form->values({
        username => $user->username,
        password => $user->password,
        confirm_password => $user->password,
        first_name => $profile->first_name,
        last_name => $profile->last_name
    });

    if ($self->submitted && $self->validate->success) {
        $profile->first_name($form->field('first_name'));
        $profile->last_name($form->field('last_name'));
        $profile->update;

        $c->user->refresh;
    };
};

1;