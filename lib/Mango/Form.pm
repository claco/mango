# $Id$
package Mango::Form;
use strict;
use warnings;

BEGIN {
    use base qw/Class::Accessor::Grouped/;
    use Mango::Form::Results;
    use Mango::Exception qw/:try/;
    use Mango::I18N ();
    use FormValidator::Simple 0.17 ();
    use CGI::FormBuilder ();
    use Clone ();
    use YAML ();

    __PACKAGE__->mk_group_accessors('simple', qw/messages profile validator _form localizer/);
};

sub new {
    my $class = shift;
    my $args  = shift || {};
    my $source = $args->{'source'} || {};

    my $self = bless {
        messages => {},
        profile => [],
        validator => FormValidator::Simple->new,
        localizer => $args->{'localizer'} || \&Mango::I18N::translate
    }, $class;

    $self->parse($source);

    return $self;
};

sub parse {
    my ($self, $source) = @_;
    my $config;

    if (!ref $source) {
        $config = YAML::LoadFile($source);
    } elsif (ref $source eq 'HASH') {
        $config = Clone::clone($source);
    } else {
        Mango::Exception->throw('UNKNOWN_FORM_SOURCE');
    };

    my $fields = $config->{'fields'};
    my $field_order = $config->{'field_order'};
    $self->_form(
        CGI::FormBuilder->new(%{$config})
    );

    foreach (@{$fields}) {
        my ($name, $field) = %{$_};
        my $label = 'LABEL_' . uc $name;
        my $constraints = delete $field->{'constraints'};
        my $errors = delete $field->{'messages'};

        $self->_form->field($name,
            label => $label,
            %{$field}
        );

        if ($constraints) {
            my @constraints;
            my @additional;

            push @{$self->profile}, $name;
            foreach my $constraint (@{$constraints}) {
                my ($cname, @args) = split /, ?/, $constraint;
                $cname = uc $cname;

                if ($cname eq 'SAME_AS') {
                    my $mname = uc $name . '_' . $cname . '_' . uc $args[0];
                    $self->messages->{$mname}->{'DUPLICATION'} = $mname;
                    push @additional, {$mname => [$name, @args]}, ['DUPLICATION'];
                } else {
                    $self->messages->{$name}->{$cname} = $errors->{$cname} || (uc $name . '_' . $cname);
                    push @constraints, scalar @args ? [$cname, @args] : $cname;
                };
            };
            push @{$self->profile}, \@constraints, @additional;
        };
    };
    
    $self->_form->submit('LABEL_SUBMIT') unless $config->{'submit'};
    $self->validator->set_messages({'.' => $self->messages});

    return;
};

sub params {
    my ($self, $object) = @_;

    if ($object) {
        $self->_form->{'params'} = $object;
    };

    return $self->_form->{'params'};
};

sub validate {
    my $self = shift;
    $self->validator->results->clear;

    ## bah! why can't we just get $form->values?
    my %values = map {$_->name, $_->value} $self->_form->fields;
    my $results = $self->validator->check(
        \%values,
        Clone::clone($self->profile)
    );

    my $messages = $results->messages('.');
    my @errors;

    foreach my $message (@{$messages}) {
        push @errors, $self->localizer->(split /, ?/, $message);
    };

    return Mango::Form::Results->new({
        _results => $results,
        errors => \@errors
    });
};

sub AUTOLOAD {
    my ($method) = (our $AUTOLOAD =~ /([^:]+)$/);
    return if $method =~ /(DESTROY)/;

    return shift->_form->$method(@_);
};

1;
__END__