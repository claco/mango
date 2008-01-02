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

1;


=head1 NAME

Mango::Catalyst::Controller - Base controller for Catalyst controllers in Mango

=head1 SYNOPSIS

    package MyApp::Controller::Foo;
    use base 'Mango::Catalyst::Controller';

=head1 DESCRIPTION

Mango::Catalyst::Controller is the base controller class used by all
Catalyst controllers in Mango. It inherits the Form and REST controllers
and provides some generic methods used by all Mango controllers.

=head1 CONFIGURATION

The following configuration options are used directly by this controller:

=over

=item resource_name

If specified, this name will be sent to C<register_as_resource> when the
component is loaded.

=back

=head1 METHODS

=head2 current_page

Returns the current page number from params or 1 if no page is specified.

=head2 entries_per_page

Returns the number of entries par page to be displayed from params
or 10 if no param is specified.

=head2 register_as_resource

=over

=item Arguments: $name

=back

Registers the current class name as a resource associated with the
specified name.

=head1 SEE ALSO

L<Mango::Catalyst::Controller::Form>, L<Mango::Catalyst::Controller::REST>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
