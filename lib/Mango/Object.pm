# $Id$
package Mango::Object;
use strict;
use warnings;

BEGIN {
    use base qw/Class::Accessor::Grouped/;
    use English '-no_match_vars';
    use Mango::Object::Meta;

    __PACKAGE__->mk_group_accessors( 'simple', qw/_meta_data _meta_object/ );
    __PACKAGE__->mk_group_accessors( 'column', qw/id created updated/ );
    __PACKAGE__->mk_group_accessors( 'component_class', qw/meta_class/ );
}
__PACKAGE__->meta_class('Mango::Object::Meta');

sub new {
    my $class = shift;
    my $self = bless shift || {}, $class;

    if ( my $meta = delete $self->{'meta'} ) {
        $self->_meta_data($meta);
    }

    if ( my $meta_class = delete $self->{'meta_class'} ) {
        $self->meta_class($meta_class);
    }

    return $self;
}

sub meta {
    my $self = shift;

    if ( !$self->_meta_object ) {
        if ( !$self->_meta_data ) {
            $self->_meta_data( {} );
        }
        $self->_meta_object( $self->meta_class->new( $self->_meta_data ) );
    }

    return $self->_meta_object;
}

sub get_column {
    my ( $self, $column ) = @_;

    return $self->{$column};
}

sub get_columns {
    my $self = shift;
    my %columns;

    foreach my $column ( keys %{$self} ) {
        next if $column =~ /^_/;

        $columns{$column} = $self->{$column};
    }

    return %columns;
}

sub set_column {
    my ( $self, $column, $value ) = @_;

    return $self->{$column} = $value;
}

sub destroy {
    my $self = shift;

    return $self->meta->provider->delete($self);
}

sub update {
    my $self = shift;

    return $self->meta->provider->update($self);
}

## these need to go into CAG so I can stop repeating myself when using CAG
## in projects
sub get_component_class {
    my ( $self, $field ) = @_;

    return $self->get_inherited($field);
}

sub set_component_class {
    my ( $self, $field, $value ) = @_;

    if ($value) {
        require Class::Inspector;
        if ( !Class::Inspector->loaded($value) ) {
            eval "use $value";    ## no critic

            if ($EVAL_ERROR) {
                Mango::Exception->throw( 'COMPCLASS_NOT_LOADED', $field,
                    $value, $EVAL_ERROR );
            }
        }

        $self->set_inherited( $field, $value );
    } else {
        Mango::Exception->throw( 'COMPCLASS_NOT_SPECIFIED', $field );
    }

    return;
}
1;
__END__

=head1 NAME

Mango::Object - Base class used for Mango result objects.

=head1 SYNOPSIS

    package Mango::User;
    use base qw/Mango::Object/;

=head1 DESCRIPTION

Mango::Object is the base class for all result objects in Mango. It provides
common methods exposed by all results like L</id>, L</created>, L</updated>,
L</update>, etc.

=head1 CONSTRUCTOR

=head2 new

=over

=item Arguments: \%args

=back

Creates a new object, assigned each name/value pair to columns of the same
name. In addition to using the column names, the following special keys are
available:

=over

=item meta

This is a hash containing the meta data for the object being created:

    my $object = Mango::Object->new({
        col1 => 'foo',
        col2 => 12,
        meta => {
            provider => $provider
        }
    });
    
    $object->meta->provider->delete(...);

=item meta_class

See L</meta_class>.

=back

=head1 METHODS

=head2 created

Returns the date and time in UTC the object was created as a DateTime object.

    print $object->created;

=head2 destroy

Deletes the current object from the provider.

=head2 get_column

=over

=item Arguments: $column

=back

Returns the value of the specified column from L</data>.

    print $object->get_column('foo');
    # same as $object->foo;

=head2 get_columns

Returns a hash of all columns as name/value pairs.

    my %columns = $object->get_columns;

=head2 id

Returns id of the current object.

    print $object->id;

=head2 meta

Returns the meta information for the current object. The default meta class is
Mango::Object::Meta.

    my $provider = $object->meta->provider;

=head2 meta_class

=over

=item Arguments: $class

=back

Gets/sets the class to be used to handle meta data for objects.

    Mango::Object->meta_class('MyMetaClass');

This can also be set on a per object basis in the constructor:

    my $object = Mango::Object->new({
        meta => {...},
        meta_class => 'MyMetaClass'
    });

=head2 set_column

=over

=item Arguments: $column, $value

=back

Sets the value of the specified column.

    $object->set_column('foo', 'bar');
    # same as $object->foo('bar');

=head2 update

Saves any changes made to the object back to the provider.

    $object->foo(2);
    $object->update;

Whenever L</update> is called, L</updated> is automatically set to the
current time in UTC.

=head2 updated

Returns the date and time in UTC the object was last updated as a DateTime
object.

    print $object->updated;

=head2 get_component_class

=over

=item Arguments: $name

=back

Gets the current class for the specified component name.

    my $class = $self->get_component_class('result_class');

There is no good reason to use this. Use the specific class accessors instead.

=head2 set_component_class

=over

=item Arguments: $name, $value

=back

Sets the current class for the specified component name.

    $self->set_component_class('result_class', 'MyItemClass');

A L<Mango::Exception|Mango::Exception> exception will be thrown if the
specified class can not be loaded.

There is no good reason to use this. Use the specific class accessors instead.

=head1 SEE ALSO

L<Mango::Object::Meta>, L<Mango::Provider>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
