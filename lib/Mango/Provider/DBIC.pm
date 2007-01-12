# $Id$
package Mango::Provider::DBIC;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider/;
    use Mango::Schema;
    use Mango::Iterator;

    __PACKAGE__->mk_group_accessors('inherited', qw/
        schema_class
        source_name
        connection_info
        _resultset
        _schema
    /);
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

    return bless {
        result => $self->resultset->create($data)
    }, $self->result_class;
};

sub search {
    my ($self, $filter, $options) = @_;

    $filter  ||= {};
    $options ||= {};

    my $results = $self->resultset->search($filter, $options);
    if (wantarray) {
        return map {bless {result => $_}, $self->result_class} $results->all;
    } else {
        return Mango::Iterator->new({
            data => $results,
            result_class => $self->result_class
        });
    };
};

sub update {
    my ($self, $object) = @_;

    return $object->update;
};

sub delete {
    my ($self, $filter) = @_;

    return $self->resultset->search($filter)->delete_all;
};

1;
__END__
