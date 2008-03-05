# $Id$
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
__END__

=head1 NAME

Mango::Catalyst::Controller::Settings - Catalyst controller for users settings

=head1 DESCRIPTION

Mango::Catalyst::Controller::Settings provides the web interface for
users to change their website settings/preferences.

=head1 ACTIONS

=head2 profile : /settings/profile/

Updates the users profile information.

=head1 SEE ALSO

L<Mango::Catalyst::Model::Profiles>, L<Mango::Provider::Profiles>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/

