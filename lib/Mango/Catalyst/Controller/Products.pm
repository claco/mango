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
__END__

=head1 NAME

Mango::Catalyst::Controller::Products - Catalyst controller for displaying
products.

=head1 DESCRIPTION

Mango::Catalyst::Controller::products provides the web interface for
displaying products.

=head1 ACTIONS

=head2 index : /

Displays the main product page.

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
