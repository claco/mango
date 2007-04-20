# $Id$
package Mango::Object;
use strict;
use warnings;

BEGIN {
    use base qw/Class::Accessor::Grouped/;

    __PACKAGE__->mk_group_accessors('simple', qw/provider data/);
    __PACKAGE__->mk_group_accessors('column', qw/id created updated/);
};


sub new {
    my ($class, $args) = @_;

    return bless $args || {}, $class;
};

sub get_column {
    my ($self, $column) = @_;

    return $self->data->{$column};
};

sub set_column {
    my ($self, $column, $value) = @_;

    return $self->data->{$column} = $value;
};

sub destroy {
    my $self = shift;

    return $self->provider->delete($self);
};

sub update {
    my $self = shift;

    return $self->provider->update($self);
};

1;
__END__

=head1 NAME

Mango::Object - Base class used for Mango result objects.

=head1 SYNOPSIS

    package Mango::User;
    use base qw/Mango::Object/;

=head1 DESCRIPTION

Mango::Object is the base class for all result objects in Mango. It provides common
methods exposed by all results like L</id>, L</created>, L</updated>, L</update>, etc.

=head1 CONSTRUCTOR

=head2 new

=over

=item Arguments: \%args

=back

Creates a new object, blessing C<args> into the current package.

=head1 METHODS

=head2 created

Returns the date and time in UTC the object was created as a DateTime object.

    print $object->created;

=head2 data

Hash containing the raw column data for the current object.

=head2 destroy

Deletes the current object from the provider.

=head2 get_column

=over

=item Arguments: $column

=back

Returns the value of the specified column from L</data>.

    print $object->get_column('foo');
    # same as $object->foo;

=head2 id

Returns id of the current object.

    print $object->id;

=head2 provider

Gets/sets the provider which created the object.

=head2 set_column

=over

=item Arguments: $column, $value

=back

Sets the value of the specified column in C<data>.

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

=head1 SEE ALSO

L<Mango::Provider>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
