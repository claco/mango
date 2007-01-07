# $Id$
package Mango::Provider::DBIC;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider/;
    use Mango::Schema;
};
__PACKAGE__->mk_group_accessors('inherited', qw/
    source_name
    connection_info
    _resultset
    _schema
/);

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
            Mango::Schema->connect(@{$self->connection_info || []})
        );
    };

    return $self->_schema;
};

1;
__END__
