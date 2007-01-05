package Mango::Provider;
use strict;
use warnings;

BEGIN {
    use base qw/Class::Accessor::Grouped/;
};
__PACKAGE__->mk_group_accessors('inherited', qw/result_class/);

sub new {
    my ($class, $args) = @_;

    return bless $args || {}, $class;
};

sub search {
    die 'Virtual Method!';
};

1;
__END__
