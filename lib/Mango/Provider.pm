# $Id$
package Mango::Provider;
use strict;
use warnings;

BEGIN {
    use base qw/Class::Accessor::Grouped/;
    use Class::Inspector ();
    use Mango::I18N qw/translate/;

    __PACKAGE__->mk_group_accessors('component_class', qw/result_class/);
};

sub new {
    my ($class, $args) = @_;
    my $self = bless {}, $class;

    $self->setup($args);

    return $self;
};

sub setup {
    my ($self, $args) = @_;

    if (ref $args eq 'HASH') {
        map {$self->$_($args->{$_})} keys %{$args};
    };

    return;
};

sub create {
    my ($self, $data) = @_;

    die translate('VIRTUAL_METHOD');
};

sub search {
    my ($self, $filter, $options) = @_;

    die translate('VIRTUAL_METHOD');
};

sub update {
    my ($self, $object) = @_;

    die translate('VIRTUAL_METHOD');
};

sub delete {
    my ($self, $filter) = @_;

    die translate('VIRTUAL_METHOD');
};

sub get_component_class {
    my ($self, $field) = @_;

    return $self->get_inherited($field);
};

sub set_component_class {
    my ($self, $field, $value) = @_;

    if ($value) {
        if (!Class::Inspector->loaded($value)) {
            eval "use $value"; ## no critic

            die translate('COMPCLASS_NOT_LOADED', $field, $value) if $@;
        };
    };

    $self->set_inherited($field, $value);

    return;
};

1;
__END__

=head1 NAME

Mango::Provider - Provider base class

=head1 SYNOPSIS

    package MyApp::Provider::Users;
    use strict;
    use warnings;
    
    BEGIN {
        use base qw/Mango::Provider/;
    };

=head1 DESCRIPTION

Mango::Provider is a base abstract class for all providers used in Mango.

=head1 CONSTRUCTOR

=head2 new

Creates a new provider object. If options are passed into new, those are
blessed into the new object.

=over

=item Arguments: \%options

=back

    my $provider = Mango::Provider->new({
        result_class => 'MyResultClass'
    });

=head1 METHODS

=head2 create

Creates a new result of type C<result_class>.

=over

=item Arguments: \%values

A hash containing the values for the new object.

=back

    my $object = $provider->create({
        id => 23,
        thingy => 'value'
    });

=head2 search

Returns a list of objects matching the specified filter.

=over

=item Arguments: \%filter, \%options

=back

    my @objects = $provider->search({col => 'value'});

The list of available options are up to each individual provider.

=head2 update

Saves any changes made to the object back to the underlying store.

=over

=item Arguments: $object

=back

    my $object = $provider->create(\%data);
    $object->col('value');
    
    $provider->update($object);

=head2 delete

Deletes objects from the store matching the supplied filter.

=over

=item Arguments: \%filter

=back

    $provider->delete({
        col => 'value'
    });

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
