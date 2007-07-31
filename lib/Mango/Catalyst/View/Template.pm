# $Id$
package Mango::Catalyst::View::Template;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::View Class::Accessor::Grouped/;
    use Mango ();
    use Mango::Exception ();

    __PACKAGE__->mk_group_accessors('inherited', qw/wrapper content_type share_paths root_paths template_paths/);
    __PACKAGE__->mk_group_accessors('simple', qw/view_instance/);
};
__PACKAGE__->view_class('Catalyst::View::TT');
__PACKAGE__->wrapper('wrapper');

sub new {
    my $self = shift->NEXT::new(@_);
    my $c = shift;
    my $arguments = shift || {};
    my $view = 'tt';

    if ($self->view_class =~ /^Catalyst::View::(.*)$/) {
        $view = lc $1;
        $view =~ s/\:\:/-/;
    };

    ## yuck. but it works for now and the C::View::Templated will fix this
    if ($view eq 'tt') {
        $arguments->{'WRAPPER'} = $self->wrapper if $self->wrapper;
    };

    $self->view_instance(
        $self->view_class->new($c, $arguments)
    );

    if (!$self->template_paths) {
        $self->template_paths([]);
        foreach my $path (@{$self->root_paths}) {
            $path = $c->path_to('root', $path);
            $path =~ s/\%view/$view/g;

            push @{$self->template_paths}, $path;
        };
        foreach my $path (@{$self->share_paths}) {
            $path = Path::Class::Dir->new(Mango->share, $path);
            $path =~ s/\%view/$view/g;

            push @{$self->template_paths}, $path;
        };
    };

    if ($view eq 'tt') {
        @{$self->view_instance->include_path} = (@{$self->template_paths});
    };

    return $self;
};

sub view_class {
    my ($self, $view) = @_;
    my $class = ref $self || $self;

    if ($view) {
        no strict 'refs';

        eval "require $view";
        Mango::Exception->throw('VIEW_CLASS_NOT_LOADED', $view, $@) if $@;

        $self->set_inherited('view_class', $view);
    };

    $self->get_inherited('view_class');
};

sub process {
    my $self = shift;
    my $c = $_[0];

    if ($c->action->attributes->{'Template'}) {
        $c->stash->{'template'} ||= $c->action->attributes->{'Template'}->[0];
    };

    my $result = $self->view_instance->process(@_);

    if ($self->content_type) {
        $_[0]->response->content_type($self->content_type);
    };

    return $result;
};

1;
__END__

=head1 NAME

Mango::Catalyst::View::Template - View class for template based output

=head1 SYNOPSIS

    $c->view('Template');

=head1 DESCRIPTION

Mango::Catalyst::View::Template renders content using one of the following
supported Catalyst views:

    Catalyst::View::TT

and serves it with the C<content_type> specified.

=head1 CONSTRUCTOR

=head2 new

=over

=item Arguments: $c

=back

Creates a new view for use in Catalyst.

=head1 ATTRIBUTES

The following method attribute are available:

=head2 Template

=over

=item Arguments: $template

=back

Sets the template to be used for the current action.

=head1 METHODS

=head2 content_type

=over

=item Arguments: $content_type

=back

Gets/sets the value of the Content-Type header to get sent with the rendered
output.

    $self->content_type('text/html');

=head2 process

Renders content using the specified C<view_class> and sets the C<content_type>.

=head2 share_paths

=over

=item Arguments: \@paths

=back

Gets/sets the list of paths in the share containing templates for the current
view.

    $self->share_paths([
        '/share/templates',
        '/share/other/templates'
    ]);

=head2 root_paths

=over

=item Arguments: \@paths

=back

Gets/sets the list of paths in the application root containing templates for
the current view.

    $self->root_paths([
        'templates',
        'other/templates'
    ]);

=head2 template_paths

=over

=item Arguments: \@paths

=back

Gets/sets the aggregate list of paths in containing templates for the current
view. By default, this will be (@root_paths, @share_paths).

    $self->template_paths([
        'templates',
        'other/templates'
        '/share/templates',
        '/share/other/templates'
    ]);

When C<process> is called, the paths in C<template_paths> will be send to the
underlying view instance template search path.

=head2 view_class

=over

=item Arguments: $view_class

=back

Gets/sets the name of the view class to be used to render content. The default
view class is Catalyst::View::TT.

    $self->view_class('Catalyst::View::TT');

An exception is thrown if the view class can not be loaded.

=head2 view_instance

=over

=item Arguments: $view_instance

=back

Gets/sets the instance of the view class to be used to render content.

=over

=item Arguments: $wrapper

=back

Gets/sets the name of the template wrapper to be used around rendered content.

    $self->wrapper('wrapper');

=head1 SUBCLASSING

Mango::Catalyst::View::Template is the base class for the Text/HTML/XHTML views
in Mango. This view is not really meant to be used directly. In most cases, you
can simply alter functionality by setting properties of your app specific view
subclasses:

    MyApp::View::Text;
    use strict;
    use warnings;
    use base qw/Mango::Catalyst::Text/;
    
    __PACKAGE__->share('/alternate/share/path);
    __PACKAGE__->view_class('Catalyst::View::MicroMason');
    __PACKAGE__->template_paths([
        '/path/to/root/tempates/mason/components/text'
    ]);
    
    1;

Of course, you can always just roll your own view and use Catalyst::View::TT and
the like directly.

=head1 TEMPLATES

When a new instance of the C<view_class> is created, it is given the list of
template paths in C<template_paths> in which to search for template files.

If <template_paths> is not already defined, the following directories are added
in the following order:

    $c->path_to('root')/root_paths
    $c->share/share_paths

If the paths have '%view' in them, that will be replace with the short name of
the specified C<view_class>:

    $self->view_class('Catalyst::View::TT');
    'templates/%view/text' becomes 'templates/tt/text'
    
    $self->view_class('Catalyst::View::Mason');
    'templates/%view/text' becomes 'templates/mason/text'
    
    $self->view_class('Catalyst::View::HTML::Template');
    'templates/%view/text' becomes 'templates/html-template/text'

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
