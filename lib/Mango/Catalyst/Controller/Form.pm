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
    __PACKAGE__->mk_group_accessors('component_class', qw/form_class/);
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
    my $form_class = $self->{'form_class'} || 'Mango::Form';

    $self->forms({});
    $self->form_class(
        $self->{'form_class'} || 'Mango::Form'
    );

    my $prefix = Catalyst::Utils::class2prefix($class);
    my $form_directory = $self->{'form_directory'} ||
        $c->path_to('root', 'forms', $prefix);    
    my @files = glob(
        Path::Class::File->new($form_directory, '*.yml')
    );

    foreach my $file (@files) {
        $c->log->debug("Loading Form '$file'");

        my $filename = Path::Class::file($file)->basename;
        my ($name, $directories, $suffix) = File::Basename::fileparse($filename, '.yml');
        my $action = Path::Class::dir($prefix, $name)->as_foreign('Unix');
        my $form = $self->form_class->new({
            source => $file
        });
        if ($form->action) {
            $self->forms->{$form->action} = $form;
        };
        $self->forms->{$name} = $form;
        $self->forms->{$action} = $form;
    };

    return $self;
};

sub form {
    my ($self, $name) = @_;
    my $c = $self->context;

    $name ||= $c->action;

    if (my $form = $self->forms->{$name}) {
        $form->action($c->request->uri->as_string);
        $form->params($c->request);
        $form->localizer(
            sub {$c->localize(@_)}
        );

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
    my $form = $self->form;

    return $form ? $form->validate(@_) : undef;
};

1;
