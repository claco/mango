package Mango::Catalyst::Controller::Login;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
    use Mango ();
    use Path::Class ();

    __PACKAGE__->config(
        resource_name  => 'login',
        form_directory => Path::Class::Dir->new(Mango->share, 'forms', 'login')
    );
};

sub index : Form('login') Template('login/index') {
    my ($self, $c) = @_;
    my $form = $self->form;

    if (!$c->user_exists) {
        if ($self->submitted && $self->validate->success) {
            if ($c->authenticate({
                username => $c->request->param('username'), 
                password => $c->request->param('password')
            })) {
                
                
            } else {
                warn $c->localize('LOGIN_FAILED');
                $c->stash->{'errors'} = [$c->localize('LOGIN_FAILED')];
            };
        };
    };
};

1;
