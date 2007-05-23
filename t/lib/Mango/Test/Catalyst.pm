# $Id$
package Mango::Test::Catalyst;
use strict;
use warnings;

BEGIN {
    use Carp;
    use Mango::Test::Catalyst::Request;
    use Mango::Test::Catalyst::Response;
    use Mango::Test::Catalyst::Log;
    use Mango::Test::Catalyst::Session;
};

sub new {
    my $class = shift;
    my $args = shift || {};

    $args->{'config'} ||= {};
    $args->{'stash'} ||= {};
    $args->{'session'} ||= {};
    $args->{'request'} ||= {};
    $args->{'response'} ||= {};

    return bless $args, $class;
};

sub config {
    return shift->{'config'};
};

sub stash {
    return shift->{'stash'};
};

*req = \&request;

sub request {
    my $self = shift;
    $self->{'_request'} ||=
        Mango::Test::Catalyst::Request->new($self->{'request'});

    return $self->{'_request'};
};

*res = \&response;

sub response {
    my $self = shift;
    $self->{'_response'} ||=
        Mango::Test::Catalyst::Response->new($self->{'response'});

    return $self->{'_response'};
};

sub session {
    my $self = shift;
    $self->{'_session'} ||=
        Mango::Test::Catalyst::Session->new($self->{'session'});

    return $self->{'_session'};
};

sub session_expires {

};

sub log {
    my $self = shift;
    $self->{'_log'} ||= Mango::Test::Catalyst::Log->new;

    return $self->{'_log'};
};

sub debug {

};

sub component {
    my $self = shift;
    my $name = shift;
    my $args = shift || {};
    my $context = $args->{context} || $self;

    $name = "Mango::Catalyst::$name";

    eval "require $name";

    # cat returns nothing for not found models
    return if $@;

    my $component;
    eval {
        $component = $name->COMPONENT($context, $args->{args});
    };
    croak "didn't get a model: $@" if $@ || !$component;

    return $component;
};

sub controller {
    my ($self, $name) = @_;

    return $self->component("Controller::$name");
};

sub model {
    my ($self, $name) = @_;

    return $self->component("Model::$name");
};

sub view {
    my ($self, $name) = @_;

    return $self->component("View::$name");
};

1;