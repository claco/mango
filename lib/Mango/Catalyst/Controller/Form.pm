package Mango::Catalyst::Controller::Form;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::Controller Class::Accessor::Grouped/;
    use Catalyst::Utils ();
    use CGI::FormBuilder ();
    use CGI::FormBuilder::Source::YAML ();
    use Clone ();
    use FormValidator::Simple 0.17 ();
    use YAML ();
    use Path::Class ();
    use File::Basename ();

    __PACKAGE__->mk_group_accessors('simple', qw/forms profiles messages validator/);
};

sub COMPONENT {
    my ($self, $c) = (shift->NEXT::COMPONENT(@_), shift);
    my $prefix = Catalyst::Utils::class2prefix(ref $self);
    my @files = glob(
        $c->path_to('root', 'forms', $prefix, '*.yml')
    );

    $self->forms({});
    $self->profiles({});
    $self->messages({});
    $self->validator(FormValidator::Simple->new);

    foreach my $file (@files) {
        $c->log->debug("Loading Form '$file'");

        my $filename = Path::Class::file($file)->basename;
        my ($name, $directories, $suffix) = File::Basename::fileparse($filename, '.yml');
        my $action = Path::Class::dir($prefix, $name)->as_foreign('Unix');
        my $config = YAML::LoadFile($file);
        my $field_order = delete $config->{'field_order'};
        my $fields = delete $config->{'fields'};
        my $profile = [];
        my $messages = {};

        my $form = CGI::FormBuilder->new(
            %{$config}
        );

        foreach (@{$fields}) {
            my ($name, $field) = %{$_};
            my $label = 'LABEL_' . uc $name;
            my $constraints = delete $field->{'constraints'};
            my $errors = delete $field->{'messages'};

            $form->field($name, 
                label => $label,
                %{$field}
            );

            if ($constraints) {
                my @constraints;
                my @additional;

                push @{$profile}, $name;
                foreach my $constraint (@{$constraints}) {
                    my ($cname, @args) = split /, ?/, $constraint;
                    $cname = uc $cname;

                    if ($cname eq 'SAME_AS') {
                        my $mname = uc $name . '_' . $cname . '_' . uc $args[0];
                        $messages->{$mname}->{'DUPLICATION'} = $mname;
                        push @additional, {$mname => [$name, @args]}, ['DUPLICATION'];
                    } else {
                        $messages->{$name}->{$cname} = $errors->{$cname} || (uc $name . '_' . $cname);
                        push @constraints, scalar @args ? [$cname, @args] : $cname;
                    };
                };
                push @{$profile}, \@constraints, @additional;
            };
        };
        $form->submit('LABEL_SUBMIT') unless $config->{'submit'};

        $self->forms->{$action} = $form;
        $self->profiles->{$action} = $profile;
        $self->messages->{$action} = $messages;
    };

    $self->validator->set_messages($self->messages);

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
