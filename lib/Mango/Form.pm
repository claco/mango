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
    use FormValidator::Simple::Constants ();
    use HTML::FormFu 0.02004 ();
    use Clone ();
    use YAML  ();

    __PACKAGE__->mk_group_accessors( 'simple',
        qw/labels messages profile validator _form localizer _unique _exists/
    );
}

sub new {
    my $class  = shift;
    my $args   = shift || {};
    my $source = $args->{'source'} || {};

    my $self = bless {
        labels    => $args->{'labels'}    || {},
        messages  => $args->{'messages'}  || {},
        profile   => $args->{'profile'}   || [],
        validator => $args->{'validator'} || FormValidator::Simple->new,
        localizer => $args->{'localizer'} || \&Mango::I18N::translate,
        _unique   => $args->{'unique'}    || {},
        _exists   => $args->{'exists'}    || {}
    }, $class;

    $self->parse($source);

    if ( $args->{'values'} ) {
        $self->values( $args->{'values'} );
    }

    return $self;
}

sub action {
    my ( $self, $action ) = @_;

    if ($action) {
        $self->_form->action("$action");
    }

    return $self->_form->attributes->{'action'};
}

sub clone {
    my $self      = shift;
    my $localizer = $self->localizer;
    my $params    = $self->params;

    $self->params(undef);
    $self->localizer(undef);

    my $form = Clone::clone($self);
    $form->_form( $self->_form->clone );

    $self->params($params);
    $self->localizer($localizer);

    return $form;
}

sub field {
    my $self = shift;
    my ( $name, $option, $value ) = @_;

    if ($value) {
        if ( ref $value eq 'ARRAY' ) {
            $self->_form->get_field( { name => $name } )->options($value);
        } else {
            $self->_form->get_field( { name => $name } )->value($value);
        }
    }

    return $self->_form->query->param(shift);
}

sub render {
    my $self = shift;
    my %args = @_;
    my $form = $self->_form;

    foreach my $arg ( keys %args ) {
        next if $arg =~ /values/i;
        $self->$arg( $args{$arg} );
    }

    my $fields = $form->get_fields;
    if ( my $values = $args{'values'} ) {
        for ( my $i = 0 ; $i < scalar @{$values} ; $i++ ) {    ## no critic
            if ( !$fields->[$i] ) {
                next;
            }

            $fields->[$i]->value( $values->[$i] );
        }
    }

    $form->process;

    ## this is a quick hack until I can get FormFu to take a coderef for localization
    my $copy = Clone::clone($form);
    foreach my $field (@{$copy->get_fields}) {
        if (my $label = $field->label) {
            $field->label($self->localizer->($field->label));
        };
    }

    return $copy->render;
}

sub values {
    my ( $self, $values ) = @_;

    if ($values) {
        foreach my $field ( keys %{$values} ) {
            $self->_form->get_field( { name => $field } )
              ->value( $values->{$field} );
        }
    }

    return
      map { $_->name, $self->_form->query->param( $_->name ) || undef }
      @{ $self->_form->get_fields };
}

sub parse {
    my ( $self, $source ) = @_;
    my $config;

    if ( !ref $source ) {
        $config = YAML::LoadFile($source);
    } elsif ( ref $source eq 'HASH' ) {
        $config = Clone::clone($source);
    } else {
        Mango::Exception->throw('UNKNOWN_FORM_SOURCE');
    }

    my $submit    = delete $config->{'submit'} || 'BUTTON_LABEL_SUBMIT';
    my $fields    = delete $config->{'fields'};
    my $indicator = '_submitted_'
      . ( $config->{'id'} || $config->{'name'} || 'noidorname' );
    push @{$fields}, { $indicator => { type => 'Hidden', value => 1 } };
    push @{$fields}, { '_submit'  => { type => 'Submit', value => $submit } };
    $config->{'indicator'} = $indicator;

    delete $config->{'sticky'};
    delete $config->{'stylesheet'};
    delete $config->{'javascript'};

    if ( exists $config->{'name'} ) {
        $config->{'attributes'}->{'name'} = delete $config->{'name'};
    }
    $self->_form( HTML::FormFu->new($config) );
    $self->_parse_fields($fields);

    #$self->labels->{'submit'} = $config->{'submit'} || 'BUTTON_LABEL_SUBMIT';

    $self->validator->set_messages( { '.' => $self->messages } );

    return;
}

sub _parse_fields {
    my ( $self, $fields ) = @_;

    foreach ( @{$fields} ) {
        my ( $name, $field ) = %{$_};
        my $label       = 'FIELD_LABEL_' . uc $name;
        my $constraints = delete $field->{'constraints'};
        my $errors      = delete $field->{'messages'};

        ## transform types
        my $type = delete $field->{'type'};
        $type ||= 'Text';
        $type =~ s/text/Text/i;
        $type =~ s/hidden/Hidden/i;
        $type =~ s/password/Password/i;
        $type =~ s/select/Select/i;
        $type =~ s/checkbox/Checkbox/i;
        $type =~ s/fieldset/Fieldset/i;

        if (   $type eq 'Checkbox'
            && exists $field->{'multiple'}
            && $field->{'multiple'} )
        {
            $type = 'Checkboxgroup';
        }
        if ( $type !~ /Submit|Fieldset/i ) {
            if (   !exists $field->{'label'}
                && !exists $field->{'label_loc'}
                && !exists $field->{'label_xml'} )
            {
                $field->{'label_loc'} = $label;
            }
        }

        ## migrate disabled
        if ( exists $field->{'force'} ) {
            $field->{'force_default'} = delete $field->{'force'};
        }
        if ( exists $field->{'force_default'} ) {
            $field->{'retain_default'} = $field->{'force_default'};
        }
        if ( exists $field->{'disabled'} ) {
            $field->{'attributes'}->{'disabled'} =
              delete $field->{'disabled'};
        }

        ## migrate options/option labels
        my $options = delete $field->{'options'};
        my $labels  = delete $field->{'labels'};

        if ($options) {
            $field->{'options'} =
              [ map { [ $_ => $labels->{$_} ] } @{$options} ];
        }

        ## delete unknowns
        delete $field->{'selectname'};
        delete $field->{'multiple'};

        $self->_form->element(
            {
                name => $name,
                type => $type,
                %{$field}
            }
        );
        $self->_parse_constraints( $name, $constraints, $errors );
    }

    return;
}

sub _parse_constraints {
    my ( $self, $name, $constraints, $errors ) = @_;

    if ($constraints) {
        my @constraints;
        my @additional;

        push @{ $self->profile }, $name;
        foreach my $constraint ( @{$constraints} ) {
            my ( $cname, @args ) = split /, ?/, $constraint;
            $cname = uc $cname;

            if ( $cname =~ /(NOT_)?SAME_AS/ ) {
                my $mname =
                  'CONSTRAINT_' . uc $name . '_' . $cname . '_' . uc $args[0];
                $self->messages->{$mname}->{ ( $1 || '' ) . 'DUPLICATION' } =
                  $mname;
                push @additional, { $mname => [ $name, @args ] },
                  [ ( $1 || '' ) . 'DUPLICATION' ];
            } else {
                if ( $cname eq 'UNIQUE' && !$self->unique($name) ) {
                    if ( !scalar @args ) {
                        push @args, $name;
                    }

                    $self->unique(
                        $name,
                        sub {
                            return FormValidator::Simple::Constants::FALSE;
                        }
                    );
                }
                if ( $cname eq 'EXISTS' && !$self->exists($name) ) {
                    if ( !scalar @args ) {
                        push @args, $name;
                    }

                    $self->exists(
                        $name,
                        sub {
                            return FormValidator::Simple::Constants::FALSE;
                        }
                    );
                }
                $self->messages->{$name}->{$cname} = $errors->{$cname}
                  || ( 'CONSTRAINT_' . uc $name . '_' . $cname );
                push @constraints, scalar @args ? [ $cname, @args ] : $cname;
            }
        }
        push @{ $self->profile }, \@constraints, @additional;
    }

    return;
}

sub params {
    my $self = shift;

    if (@_) {
        $self->_form->query(shift);
    }

    return $self->_form->query;
}

sub exists {
    my ( $self, $field, $code ) = @_;

    if ( ref $code eq 'CODE' ) {
        $self->_exists->{$field} = $code;
    }

    return $self->_exists->{$field};
}

sub unique {
    my ( $self, $field, $code ) = @_;

    if ( ref $code eq 'CODE' ) {
        $self->_unique->{$field} = $code;
    }

    return $self->_unique->{$field};
}

sub validate {
    my $self = shift;
    $self->validator->results->clear;

    $self->_form->process;

    ## ugly. this will go when I move to Reaction :-)
    local *FormValidator::Simple::Validator::UNIQUE = sub {
        my ( $i, $params, $args ) = @_;
        my $value = $params->[0];
        my $field = $args->[0];

        my $result = $self->unique($field)->( $self, $field, $value );

        return $result
          ? FormValidator::Simple::Constants::TRUE
          : FormValidator::Simple::Constants::FALSE;
    };
    local *FormValidator::Simple::Validator::EXISTS = sub {
        my ( $i, $params, $args ) = @_;
        my $value = $params->[0];
        my $field = $args->[0];

        my $result = $self->exists($field)->( $self, $field, $value );

        return $result
          ? FormValidator::Simple::Constants::TRUE
          : FormValidator::Simple::Constants::FALSE;
    };

    ## bah! why can't we just get $form->values?
    my %values = $self->values;
    my $results =
      $self->validator->check( \%values, Clone::clone( $self->profile ) );

    my $messages = $results->messages('.');
    my @errors;

    foreach my $message ( @{$messages} ) {
        push @errors, $self->localizer->( split /, ?/, $message );
    }

    return Mango::Form::Results->new(
        {
            _results => $results,
            errors   => \@errors
        }
    );
}

sub submitted {
    my $self = shift;

    $self->_form->process;

    return $self->_form->submitted;
}

sub AUTOLOAD {
    my $self = shift;
    my ($method) = ( our $AUTOLOAD =~ /([^:]+)$/ );
    return if $method =~ /(DESTROY)/;

    return $self->_form->$method(@_);
}

1;
__END__

=head1 NAME

Mango::Form - Module representing an input form

=head1 SYNOPSIS

    my $form = Mango::Form->new({
        source => 'path/to/some/config.yml'
    });

=head1 DESCRIPTION

Mango::Form renders forms using CGI::FormBuilder and validates data using
FormValidator::Simple, all from a single configuration format.

=head1 FORM FILE FORMAT

The form file format is YAML. The top level options are passed directly
to CGI::FormBuilder. The collection of C<fields> are parsed out into
FormBuilder field specs and sent to FormBuilder. The C<constraints> are
FormValidator::Simple constraint names.

    ---
    name: form_name
    method: POST
    javascript: 0
    stylesheet: 1
    sticky: 1
    submit: LABEL_CREATE
    fields:
      - sku:
          type: text
          size: 25
          maxlength: 25
          constraints:
            - NOT_BLANK
            - LENGTH, 1, 25
            - UNIQUE
      - name:
          type: text
          size: 25
          maxlength: 25
          constraints:
            - NOT_BLANK
            - LENGTH, 1, 25
      - description:
          type: text
          size: 50
          maxlength: 100
          constraints:
            - NOT_BLANK
            - LENGTH, 1, 100
      - price:
          type: text
          size: 25
          maxlength: 12
          constraints:
            - NOT_BLANK
            - DECIMAL, 9, 2
      - tags:
          type: textarea

=head2 constraints

Each constraint in the constraints collection is the name of a
FormValidator::Simple validation command. You can pass options to that command
by simply adding to that line separated by commas.

The C<UNIQUE> constraint is specific to Mango::Form. When specified, it will
run the code reference associated with the current field. You can use a
different field name by passing it as another option:

    - sku:
        type: text
        size: 25
        maxlength: 25
        constraints:
          - NOT_BLANK
          - LENGTH, 1, 25
          - UNIQUE, part_number

By default, all UNIQUE constraints will fail, unless you tell the form how to
validate that field. You can do this by calling L</unique>:

    $form->unique('sku', sub {
        my ($self, $field, $value) = @_;
        ...determine if sku exists
        return $exists ? 1 : 0;
    });

=head2 messages

The messages default to FIELDNAME_CONSTRAINTNAME, which is then localized. In
the example above, the error message returned when the sku was blank would be
SKU_NOT_BLANK. When the price failed the decimal check, PRICE_DECIMAL is
returned, etc.

You can override these defaults to use your own message key, or provide a
complete text message itself using the C<messages> collection and assigning
the new message to the same constraint name:

    - sku:
        type: text
        size: 25
        maxlength: 25
        constraints:
          - NOT_BLANK
          - LENGTH, 1, 25
          - UNIQUE, part_number
        messages:
          NOT_BLANK: "sku cannot be blank"
          LENGTH: "sku is too long"
          UNIQUE: "sku already exists"

=head2 localization

When running by itself, messages and field labels are localized using
Mango::I18N. While running under the Mango Catalyst controllers,
$c->localize is used to localize the messages and labels, which will use
MyApp::I18N or MyApp::L10N. You can also use your own localizer by passing
a code reference into the C<localizer> property:

    $form->localizer(sub {
        my $message, $args) = @_;
        ...localize magic
    });

=head1 CONSTRUCTOR

=head2 new

=over

=item Arguments: \%options

=back

Creates a new Mano::Form object. The following options are available:

    my $form = Mango::Form->new({
        source => 'thisform.yml',
        unique => {
            field => \&field_is_unique
        },
        localizer => sub {
            MyApp->localize(@_);
        }
    });

=over

=item source

A string containing the path to the config file, or a hash reference
containing the same configuration data.

=item validator

 An instance of the validator to be used. This is an instance of
 FormValidator::Simple by default. Using anything else at this time will
 probably not work. :-)

=item localizer

A code reference to be used to localize the field labels, buttons and
messages.

=item exists

A hash reference containing methods to be used to determine if s fields values
already exists.

=item unique

A hash reference containing methods to be used to determine field value
uniqueness.

=item values

A hash reference containing the default form field values.

=back

=head1 METHODS

=head2 action

=over

=item Arguments: $action

=back

Gets/sets the action for the current form.

=head2 clone

Creates and returns a clone of the current form.

=head2 exists

=over

=item Arguments: $field, \&code

=back

Gets/sets the code reference to be used to determine if a fields value
already exists.

    $form->exists('field')->($self, 'field', 'value');
    $form->exists('field', sub {
        my ($self, $field, $value) = @_;
        ...exists magic...
    };

=head2 field

=over

=item Arguments: $name or %options

=back

Gets/sets a form fields information and other options.

    my $field = $form->field('sku');
    $form->field(name => 'sku', options => [...]);

See L<CGI::FormBuilder/field> for more information.

=head2 localizer

=over

=item Arguments \&sub

=back

Gets/sets the code reference used to localize form field labels, buttons and
messages.

    $form->localizer(
        sub {
            my $self = shift;
            return MyApp->localize(@_);
        }
    );

=head2 params

=over

=item Arguments: $object

=back

Gets/sets the object to read params from. This can be a CGI object, the
Catalyst::Request object, or any other object that supports the param()
method.

    $form->params($r);

=head2 parse

=over

=item Arguments: $source

=back

Parses the specified configuration and creates the appropriate forms, fields,
constraints and messages.

    $form->parse('/myform.yml');

C<source> can be either a string containing the configuration file name,
or a hash reference containing the same data structure.

=head2 render

Returns the html source for the current form.

=head2 submitted

Returns true if the form has been submitted.

    if ($form->submitted) {
        ...
    };

=head2 unique

=over

=item Arguments: $field, \&code

=back

Gets/sets the code reference to be used to determine if a field value
is unique or not.

    $form->unique('field')->($self, 'field', 'value');
    $form->unique('field', sub {
        my ($self, $field, $value) = @_;
        ...unique magic...
    };

=head2 validate

Validates the current for values against the constraints and returns
a Mango::Form::Results instance.

    my $results = $form->validate;
    if ($results->success) {
        ...save to db...
    } else {
        my $errors = $results->errors;
        ...
    };

=head2 values

=over

=item Arguments: \%values

=back

Gets/sets the current form fields values.

    my %values = $form->values;
    $form->values({
        field11 => 'Foo',
        field2  => 2
    });

=head1 SEE ALSO

L<Mango::Form::Results>, L<HTML::FormFu>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
