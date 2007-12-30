package Mango::Catalyst::Controller;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller::REST Mango::Catalyst::Controller::Form/;
    use URI ();
    use Path::Class::Dir ();
};

sub COMPONENT {
    my $self = shift->NEXT::COMPONENT(@_);

    if (exists $self->{'resource_name'} && $self->{'resource_name'}) {
        $self->register_as_resource($self->{'resource_name'});
    };

    return $self;
};

sub _parse_PathPrefix_attr {
    my ($self, $c, $name, $value) = @_;

    return PathPart => $self->path_prefix;
};

sub _parse_Chained_attr {
    my ($self, $c, $name, $value) = @_;

    if ($value && $value =~ /\.\.\//) {
        ## this is a friggin hack because I don't know how to have
        ## Path::Class eval ../ for me
        local $URI::ABS_REMOTE_LEADING_DOTS = 1;
        $value = URI->new(
            Path::Class::Dir->new($self->action_namespace, $value)->stringify
        )->abs('http://localhost')->path('foo');
    };

    return Chained => $value || $self->action_namespace;
};

sub register_as_resource {
    my ($self, $name) = @_;
    my $class = ref $self || $self;

    $self->context->register_resource($name, $class);

    return;
};

sub current_page {
    my $c = shift->context;
    return $c->request->param('current_page') || 1;
};

sub entries_per_page {
    my $c = shift->context;
    return $c->request->param('entries_per_page') || 10;
};

## this sucks. REST exposes validate via Params::Validate :all and I have an
## ISA ordering issue with that
sub validate {
    my $self = shift;

    if ($self->wants_browser) {
        return Mango::Catalyst::Controller::Form::validate($self, @_);
    } else {
        return $self->SUPER::validate(@_);
    };
};

1;
