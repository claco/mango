# $Id$
package Mango::Catalyst::Controller::Form;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::Controller Class::Accessor::Grouped/;
    use Catalyst::Utils ();
    use Path::Class ();
    use File::Basename ();
    use Scalar::Util qw/blessed weaken/;

    __PACKAGE__->mk_group_accessors('simple', qw/forms context/);
    __PACKAGE__->mk_group_accessors('inherited', qw/form_directory/);
    __PACKAGE__->mk_group_accessors('component_class', qw/form_class/);
};
__PACKAGE__->form_class('Mango::Form');

sub _parse_Form_attr {
    my ($self, $c, $name, $value) = @_;

    if (my $form = $self->forms->{$value}) {
        return Form => $form;
    };

    return;
};

sub _parse_FormFile_attr {
    my ($self, $c, $name, $value) = @_;

    if (my $form = $self->_load_form_from_file($c, $value)) {
        return Form => $form;
    };

    return;
};

sub ACCEPT_CONTEXT {
    my $self = shift;
    my ($c, @args) = @_;

    weaken($c);
    $self->context($c);

    return $self;
};

sub COMPONENT {
    my $class = shift;
    my $self = $class->NEXT::COMPONENT(@_);
    my $c = shift;
    my $prefix = Catalyst::Utils::class2prefix($class);

    if (my $form_class = $self->{'form_class'}) {
        $self->form_class($form_class);
    };
    $self->forms({});

    if (my $form_directory = $self->{'form_directory'}) {
        $self->form_directory($form_directory);  
    };
    if (!$self->form_directory) {
        $self->form_directory(
            $c->path_to('root', 'forms', $prefix)
        );
    };

    my @files = glob(
        Path::Class::File->new($self->form_directory, '*.yml')
    );

    foreach my $file (@files) {
        my $filename = Path::Class::file($file)->basename;
        my ($name, $directories, $suffix) = File::Basename::fileparse($filename, '.yml');
        my $action = Path::Class::dir($prefix, $name)->as_foreign('Unix');

        my $form = $self->_load_form_from_file($c, $file);
        if ($form->action) {
            $self->forms->{$form->action} = $form;
        };

        $c->log->debug("Form $filename attached to action '$action'");
        $self->forms->{$name} = $form;
        $self->forms->{$action} = $form;
    };

    return $self;
};

sub _load_form_from_file {
    my ($self, $c, $file) = @_;

    $c->log->debug("Loading form '$file'");

    return $self->form_class->new({
        source => $file
    });
};

sub form {
    my ($self, $name) = @_;
    my $c = $self->context;
    my $form;

    $name ||= $c->action;

    if (exists $c->action->attributes->{'Form'}) {
        $form = $c->action->attributes->{'Form'}->[-1];
    };

    if (!$form) {
        $form = $self->forms->{$name};
    };

    if ($form) {
        $form->action($c->request->uri->as_string);
        $form->params($c->request);
        $form->localizer(
            sub {$c->localize(@_)}
        );

        $c->stash->{'form'} = $form;

        return $form;
    };

    return;
};

sub submitted {
    my $self = shift;
    my $form = $self->form;

    return $form ? $form->submitted : undef;
};

sub validate {
    my $self = shift;
    my $c = $self->context;
    my $form = $self->form;
    my $results = $form->validate(@_);

    $c->stash('errors') = $results->errors;

    return $results;
};

1;
__END__

=head1 NAME

Mango::Catalyst::Controller::Form - Catalyst controller for form based activity.

=head1 SYNOPSIS

    package MyApp::Controller::Stuff;
    use base qw/Mango::Catalyst:Controller::Form/;
    
    sub edit : Local {
        my ($self, $c) = @_;
        if ($self->submitted) {
            my $results = $self->validate;
            if ($results->success) {
                ...
            };
        };
    };

=head1 DESCRIPTION

Mango::Catalyst::Controller::Form is a base Catalyst controller that
automatically loads forms based on the current class/action using Mango::Form.

By default, this controller loads all forms from a directory named after the
current controller in the root/forms directory and assigns them to the
actions in that controller matching the name of the form file themselves.

For example:

    ## controller
    MyApp::Controller::Foo::Bar;
    
    ## directory/files
    root/forms/foo/bar/create.yml
    root/forms/foo/bar/edit.yml
    
    ## actions
    sub create : Local {
        $self->form; ## create.yml form
    };
    
    sub edit : Local {
        $self->form; ## edit.yml form
    };

IF you would like to load forms from a different directory, specify that
directory using the C<form_directory> configuration option below.

head1 CONFIGURATION

The following configuration options are used directly by this controller:

=over

=item form_class

The form class used to parse/validate forms. The default class is Mango::Form.

    __PACKAGE__->config(
        form_class => 'MyApp::Form'
    );

=item form_directory

The directory to load forms from. If no directory is specified, forms in the current
class2prefix are loaded instead.

    __PACKAGE__->config(
        form_directory => '/path/to/this/classes/forms'
    );

=back

=head1 ATTRIBUTES

The following method attribute are available:

=head2 Form

=over

=item Arguments: $name

=back

Set the name of the form to use for the current method/action.

    sub create : Form('myform') Local {
        my $self = shift;
        my $form = $self->form;  # returns myform.yml form
    };

=head2 FormFile

=over

=item Arguments: $file

=back

Sets the file name of the form to use for the current method/action.

    sub create : FormFile('/path/to/myform.yml') Local {
        my $self = shift;
        my $form = $self->form;  # returns myform.yml form
    };

=head1 METHODS

=head2 COMPONENT

Creates an instance of the current controller and loads all available forms
from the appropriate directory.

=head2 ACCEPT_CONTEXT

Accepts the current context and stores a weakened reference to it. This is
just a hack so $self->form can access context without having to call
$c->forward('form') all the time.

=head2 form

=over

=item Arguments: $name

=back

Gets the form for the current action.

    sub edit : Local {
        $self->form; ## root/forms/controller/name/edit.yml
    };

If you wish to work with a specific form, simply pass the name of that file,
without the .yml extension, to C<form>:

    sub foo : Local {
        $self->form('edit'); ## root/forms/controller/name/edit.yml
    };

When a form is returns, the following are set automatically:

=over

=item params are set to $c->request

=item action is set to $c->action

=item localizer is set to $c->localize

=back

=head2 form_class

=over

=item Arguments: $class

=back

Gets/sets the form class to be used when loading/validating forms. The default
class is Mango::Form.

    __PACKAGE__->form_class('MyApp::Form');

=head2 form_directory

=over

=item Arguments: $directory

=back

Gets/sets the form_directory where forms should be loaded from.

    __PACKAGE__->form_directory('/path/to/controllers/forms/');

=head2 submitted

Returns true if the current form has been submitted, false otherwise.

    sub edit : Local {
        my ($self, $c) = @_;
        if ($self->submitted) {
            ...
        };
    };

=head2 validate

Returns a Mango::Results object containing the status of the current
form validation.

    sub edit : Local {
        my ($self, $c) = @_;
        if ($self->submitted) {
            my $results = $self->validate;
            if ($results->success) {
                ...
            } else {
                print @{$results->errors};
            };
        };
    };

=head1 SEE ALSO

L<Mango::Form>, L<Mango::Form::Results>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
