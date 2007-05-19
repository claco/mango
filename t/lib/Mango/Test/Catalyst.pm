# $Id$
package Mango::Test::Catalyst;
use strict;
use warnings;

BEGIN {
    use Carp;
};

## ripped from Angerwhale::Test::Application
sub context {
    my $class = shift;
    my $args = shift || {};
    my $config = $args->{'config'} || {};
    my $stash = $args->{'stash'} || {};
    my $session = $args->{'session'} || {};

    ## stupid UNIVERSAL::crap kills Template::Timer load
    require Test::MockObject;

    my $c = Test::MockObject->new;

    $c->mock('component', \&component);
    $c->mock('model', \&model);
    $c->mock('view', \&view);
    $c->mock('action', sub {return shift->config->{'action'}});
    $c->set_always('stash', $stash);
    $c->set_always('session', $session);
    $c->set_always('session_expires', undef);

    #$config = { %{$config||{}},
    #            %{LoadFile('root/resources.yml')||{}}
    #          };
    $c->set_always('config', $config);

    # fake logging (doesn't do anything)
    my $log = Test::MockObject->new;
    $log->set_always('debug', undef);
    $c->set_always('log', $log);
    $c->set_always('debug', undef);

    ## Catalyst::Request
    my $request = Test::MockObject->new;
    $request->set_always('base', undef);
    $request->mock('header', sub {
        return $config->{'request'}->{$_[1]};
    });
    $c->set_always('request', $request);
    $c->set_always('req', $request);


    ## Catalyst::Response
    my $response = Test::MockObject->new;
    $response->mock('body', sub {
        my ($self, $stuff) = @_;
        if (defined $stuff) {
            $self->{'body'} = $stuff;
        };
        return $self->{'body'};
    });
    $response->mock('content_type', sub {
        my ($self, $stuff) = @_;
        if (defined $stuff) {
            $self->{'content_type'} = $stuff;
        };
        return $self->{'content_type'};
    });
    $c->set_always('response', $response);
    $c->set_always('res', $response);

    return $c;
};

sub component {
    my $self = shift;
    my $name = shift;
    croak "need name" unless $name;
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

sub model {
    my ($self, $name) = @_;

    return $self->component("Model::$name");
};

sub view {
    my ($self, $name) = @_;

    return $self->component("View::$name");
};

1;