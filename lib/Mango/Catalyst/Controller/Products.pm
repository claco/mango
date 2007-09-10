package Mango::Catalyst::Controller::Products;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller::Form/;
};

sub index : Template('products/index') {
    my ($self, $c) = @_;

};

1;
