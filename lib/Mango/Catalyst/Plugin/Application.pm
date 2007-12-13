# $Id$
package Mango::Catalyst::Plugin::Application;
use strict;
use warnings;
our $VERSION = $Mango::VERSION;

BEGIN {
    use base qw/
        Mango::Catalyst::Plugin::Authentication
        Mango::Catalyst::Plugin::I18N
        Mango::Catalyst::Plugin::Forms
        Catalyst::Plugin::Cache
        Catalyst::Plugin::Cache::Store::Memory
    /;
};

sub register_resource {
    my ($self, $name, $class) = @_;
    $class = ref $class || $class;

    $self->config->{'mango'}->{'controllers'}->{$name} = $class;

    if ($self->debug) {
        $self->log->debug("Registering resource $class as $name");
    };

    return;
};

sub uri_for_resource {
    my ($self, $name, $action, @args) = @_;
    my $class = $self->config->{'mango'}->{'controllers'}->{$name};

    return unless $class;

    my $controller = $self->controller($class . '$');
    $action = $controller->action_for($action || 'index');

    return $self->uri_for($action, @args);
};

1;
