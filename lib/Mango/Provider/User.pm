package Mango::Provider::User;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider::Schema/;
    use Mango::User;
};
__PACKAGE__->result_class('Mango::User');
__PACKAGE__->source_name('Users');

sub search {
    my ($self, $filter, $options) = @_;

    $filter  ||= {};
    $options ||= {};

    return map {bless {result => $_}, $self->result_class} $self->resultset->search($filter, $options)->all;
};

1;
__END__
