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
            Path::Class::Dir->new($self->action_namespace, $value)->as_foreign('Unix')->stringify
        )->abs('http://localhost')->path('foo');
    };

    return Chained => $value || $self->action_namespace;
};

sub _parse_Feed_attr {
    my ($self, $c, $name, $value) = @_;

    return Feed => $value;
};

sub end : ActionClass('Serialize') {
    my $self = shift;
    my $c = shift;
    my %feeds = map { lc($_) => 1 } @{$c->action->attributes->{'Feed'} || []};

    if (exists $feeds{'atom'}) {
        $self->enable_atom_feed unless
            $c->stash->{'links'}->{'alternate'}->{'atom'};
    };
    if (exists $feeds{'rss'}) {
        $self->enable_rss_feed unless
            $c->stash->{'links'}->{'alternate'}->{'rss'};
    };

    return $self->NEXT::end($c, @_);
};

sub register_as_resource {
    my ($self, $name) = @_;
    my $class = ref $self || $self;

    $self->context->register_resource($name, $class);

    return;
};

sub current_page {
    my $c = shift->context;
    return $c->request->param('current_page') ||
        $c->request->param('page') || 1;
};

sub entries_per_page {
    my $c = shift->context;
    return $c->request->param('entries_per_page') ||
        $c->request->param('rows') || 10;
};

sub enable_feeds {
    my $self = shift;

    $self->enable_atom_feed;
    $self->enable_rss_feed;
};

sub enable_atom_feed {
    my $self = shift;
    my $c = $self->context;

    $c->stash->{'links'}->{'alternate'}->{'atom'} = $c->request->uri_with({view => 'Atom'});
};

sub enable_rss_feed {
    my $self = shift;
    my $c = $self->context;

    $c->stash->{'links'}->{'alternate'}->{'rss'} = $c->request->uri_with({view => 'RSS'});
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
