# $Id$
package Mango::Provider::DBIC;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider/;
    use Scalar::Util ();
    use DateTime ();
    use Mango::Iterator ();
    use Mango::Exception qw/:try/;

    __PACKAGE__->mk_group_accessors('component_class', qw/schema_class/);
    __PACKAGE__->mk_group_accessors('inherited', qw/
        source_name
        connection_info
        updated_column
        _resultset
        _schema
    /);

    *DBIx::Class::Row::get_inflated_columns = sub {
        my $self = shift;

        return map {$_ => $self->$_} $self->columns;
    };
};
__PACKAGE__->schema_class('Mango::Schema');
__PACKAGE__->updated_column('updated');

sub create {
    my ($self, $data) = @_;
    my $result = $self->resultset->create($data);

    return $self->result_class->new({
        provider => $self,
        data => {$result->get_inflated_columns}
    });
};

sub delete {
    my ($self, $filter) = @_;

    if (Scalar::Util::blessed $filter) {
        $filter = {id => $filter->id};
    } elsif (ref $filter ne 'HASH') {
        $filter = {id => $filter};
    };

    return $self->resultset->search($filter)->delete_all;
};

sub resultset {
    my ($self, $resultset) = @_;

    if ($resultset) {
        $self->_resultset($resultset);
    } elsif (!$self->_resultset) {
        if (!$self->source_name) {
            throw Mango::Exception('SCHEMA_SOURCE_NOT_SPECIFIED');
        };

        try {
            $self->_resultset($self->schema->resultset($self->source_name));
        } except {
            throw Mango::Exception('SCHEMA_SOURCE_NOT_FOUND', $self->source_name);
        };
    };

    return $self->_resultset;
};

sub schema {
    my ($self, $schema) = @_;

    if ($schema) {
        $self->_schema($schema);
    } elsif (!$self->_schema) {
        if (!$self->schema_class) {
            throw Mango::Exception('SCHEMA_CLASS_NOT_SPECIFIED');
        };
        $self->_schema(
            $self->schema_class->connect(@{$self->connection_info || []})
        );
    };

    return $self->_schema;
};

sub search {
    my ($self, $filter, $options) = @_;

    $filter  ||= {};
    $options ||= {};

    my $resultset = $self->resultset->search($filter, $options);
    my @results = map {
        $self->result_class->new({
            provider => $self,
            data => {$_->get_inflated_columns}
        })
    } $resultset->all;

    if (wantarray) {
        return @results;
    } else {
        return Mango::Iterator->new({
            provider => $self,
            data => \@results,
            pager => $options->{'page'} ? $resultset->pager : undef
        });
    };
};

sub update {
    my ($self, $object) = @_;
    my $updated_column = $self->updated_column;

    $object->$updated_column(DateTime->now);

    return $self->resultset->find($object->id)->update(
        {%{$object->data}}
    );
};

1;
__END__

=head1 NAME

Mango::Provider::DBIC - Provider class for DBIx::Class based providers

=head1 SYNOPSIS

    package MyApp::Provider::Users;
    use strict;
    use warnings;
    
    BEGIN {
        use base qw/Mango::Provider::DBIC/;
    };
    __PACKAGE__->schema_class('MySchema');
    __PACKAGE__->source_name('Users');
    
    my $object = $provider->create(\%data);

=head1 DESCRIPTION

Mango::Provider::DBIC is a base abstract class for all DBIx::Class based
providers used in Mango.

=head1 CONSTRUCTOR

=head2 new

=over

=item Arguments: \%options

=back

Creates a new provider object. If options are passed to new, those are
sent to C<setup>.

    my $provider = Mango::Provider::DBIC->new({
        schema_class => 'MySchema',
        source_name  => 'Users',
        result_class => 'MyResultClass'
    });

The following options are available at the class level, to new/setup and take
the same data as their method counterparts:

    connection_info
    resultset
    schema
    schema_class
    source_name

See L<Mango::Provider/new> a list of other possible options.

=head1 METHODS

=head2 connection_info

=over

=item Arguments: \@info

=back

Gets/sets the connection information used when connecting to the database.

    $provider->connection_info(['dbi:mysql:foo', 'user', 'pass', {PrintError=>1}]);

The info argument is an array ref that holds the following values:

=over

=item $dsn

The DBI dsn to use to connect to.

=item $username

The username for the database you are connecting to.

=item $password

The password for the database you are connecting to.

=item \%attr

The attributes to be pass to DBI for this connection.

=back

See L<DBI> for more information about dsns and connection attributes.

=head2 create

=over

=item Arguments: \%data

=back

Creates a new object of type C<result_class> using the supplied data.

    my $object = $provider->create({
        id => 23,
        thingy => 'value'
    });

=head2 delete

=over

=item Arguments: \%filter

=back

Deletes objects from the store matching the supplied filter.

    $provider->delete({
        col => 'value'
    });

=head2 resultset

=over

=item Arguments: $resultset

=back

Gets/sets the DBIx::Class::Resultset to be used by this provider. If no
resultset is set, the resultset for the specified C<source_name> will be
created automatically.

    $provider->resultset;
    # same as $schema->resultset($provider->source_name)
    
    $provider->resultset(
        $schema->resultset($provder->source_name)->search({default => 'search'})
    );

=head2 schema

=over

=item Arguments: $schema

=back

Gets/sets the DBIx::Class schema instance to be used for this provider. If no
schema is set, a new instance of the C<schema_class> will be created
automatically when it is needed.

    my $schema = $provider->schema;
    $schema->dbh->{'AutoCommit'} = 0;

=head2 schema_class

=over

=item Arguments: $class

=back

Gets/sets the DBIx::Class schema class to be used for this provider. An
exception will be thrown if the specified class can not be loaded.

    $provider->schema_class('MySchema');
    my $schema = $provider->schema;
    print ref $schema; # MySchema

If no schema class is specified in the subclass, the default schema class is
Mango::Schema.

=head2 search

=over

=item Arguments: \%filter, \%options

=back

Returns a list of objects in list context or a Mango::Iterator in scalar
context matching the specified filter.

    my @objects = $provider->search({
        col => 'value'
    });
    
    my $iterator = $provider->search({
        col => 'value'
    });

See L<DBIx::Class::Resultset/ATTRIBUTES> for a list of possible options.

=head2 source_name

=over

=item Arguments: $source

=back

Gets/sets the DBIx::Class schema source to be used when creating the default
resultset.

    $provider->source_name('Users');
    $provider->resultset;
    ## same as $schema->resultset('Users')

=head2 update

=over

=item Arguments: $object

=back

Sets the 'updated' column to DateTime->now and saves any changes made to the
object back to the underlying store.

    my $object = $provider->create(\%data);
    $object->col('value');
    
    $provider->update($object);

=head1 SEE ALSO

L<Mango::Provider>, L<DBIx::Class>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
