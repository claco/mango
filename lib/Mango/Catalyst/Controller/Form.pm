package Mango::Catalyst::Controller::Form;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::Controller Class::Accessor::Grouped/;
    use Catalyst::Utils ();
    use Path::Class ();
    use File::Basename ();
    use Scalar::Util qw/blessed/;

    __PACKAGE__->mk_group_accessors('simple', qw/forms/);
    __PACKAGE__->mk_group_accessors('component_class', qw/form_class/);
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
        my $form = $self->form_class->new({
            source => $file,
            localizer => sub {$c->localize(@_)}
        });

        $self->forms->{$name} = $form;
    };

    return $self;
};

sub form : Private {
    my ($self, $c, $action) = @_;

    if (!$c->stash->{'form'}) {
        $action ||= $c->action;

        my $form = $self->forms->{$action};
        $form->action($c->request->uri->as_string);
        $form->{'params'} = $c->request;

        $c->stash->{'form'} = $form;
    };

    return $c->stash->{'form'};
};

sub submitted : Private {
    my ($self, $c) = @_;

    #if ($c->request->method eq 'POST') {
        return $c->forward('form')->submitted;
    #} else {
    #    return;
    #};
};

sub validate : Private {
    my ($self, $c, $form, $action) = @_;
    $form   = $form   || $c->forward('form');
    $action = $action || $c->action;

    $self->validator->results->clear;

    ## bah! why can't we just get $form->values?
    my %values = map {$_->name, $_->value} $form->fields;
    my $results = $self->validator->check(
        \%values,
        Clone::clone($self->profiles->{$action})
    );

    if ($results->success) {
        return $results;
    } else {
        my $messages = $results->messages($action);
        my @errors;

        foreach my $message (@{$messages}) {
            push @errors, $c->localize(split /, ?/, $message);
        };

        $c->stash->{'errors'} = \@errors;
    };

    return;
};

1;
