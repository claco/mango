package Mango::Catalyst::Controller::Products;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
    use Mango ();
    use Path::Class::Dir ();

    __PACKAGE__->config(
        resource_name  => 'products',
        form_directory => Path::Class::Dir->new(Mango->share, 'forms', 'products')
    );
};

sub index : Template('products/index') {
    my ($self, $c) = @_;

};

1;
