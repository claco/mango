# $Id$
package Mango::Form;
use strict;
use warnings;

BEGIN {
    use base qw/Class::Accessor::Grouped/;
    use Mango::Exception qw/:try/;
    use FormValidator::Simple 0.17 ();
    use CGI::FormBuilder ();
    use Clone ();
    use YAML ();

    __PACKAGE__->mk_group_accessors('simple', qw/messages profile validator form/);
};

sub new {
    my $class = shift;
    my $args  = shift || {};
    my $source = $args->{'source'} || {};

    my $self = bless {
        messages => {},
        profile => [],
        validator => FormValidator::Simple->new
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
    $self->form(
        CGI::FormBuilder->new(%{$config})
    );

    foreach (@{$fields}) {
        my ($name, $field) = %{$_};
        my $label = 'LABEL_' . uc $name;
        my $constraints = delete $field->{'constraints'};
        my $errors = delete $field->{'messages'};

        $self->form->field($name,
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
    $self->form->submit('LABEL_SUBMIT') unless $config->{'submit'};

    return;
};

sub validate {

};

sub AUTOLOAD {
    my ($method) = (our $AUTOLOAD =~ /([^:]+)$/);
    return if $method =~ /(DESTROY)/;

    return shift->form->$method(@_);
};

1;
__END__