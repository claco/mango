# $Id$
package Mango::Provider::DBIC;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider/;
    use Scalar::Util ();
    use Mango::Iterator;

    __PACKAGE__->mk_group_accessors('component_class', qw/schema_class/);
    __PACKAGE__->mk_group_accessors('inherited', qw/
        source_name
        connection_info
        _resultset
        _schema
    /);

    *DBIx::Class::Row::get_inflated_columns = sub {
        my $self = shift;

        return map {$_ => $self->$_} $self->columns;
    };
};
__PACKAGE__->schema_class('Mango::Schema');

sub resultset {
    my $self = shift;

    if (!$self->_resultset) {
        $self->_resultset($self->schema->resultset($self->source_name));
    };

    return $self->_resultset;
};

sub schema {
    my $self = shift;

    if (!$self->_schema) {
        $self->_schema(
            $self->schema_class->connect(@{$self->connection_info || []})
        );
    };

    return $self->_schema;
};

sub create {
    my ($self, $data) = @_;
    my $result = $self->resultset->create($data);

    return $self->result_class->new({
        provider => $self,
        data => {$result->get_inflated_columns}
    });
};

sub search {
    my ($self, $filter, $options) = @_;

    $filter  ||= {};
    $options ||= {};

    my @results = map {
        $self->result_class->new({
            provider => $self,
            data => {$_->get_inflated_columns}
        })
    } $self->resultset->search($filter, $options)->all;

    if (wantarray) {
        return @results;
    } else {
        return Mango::Iterator->new({
            data => \@results
        });
    };
};

sub update {
    my ($self, $object) = @_;

    return $self->resultset->find($object->id)->update($object->data);
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

1;
__END__
