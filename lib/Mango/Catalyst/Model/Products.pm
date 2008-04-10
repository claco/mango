# $Id$
package Mango::Catalyst::Model::Products;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Model::Provider/;
}

__PACKAGE__->config( provider_class => 'Mango::Provider::Products' );

1;
__END__

=head1 NAME

Mango::Catalyst::Model::Products - Catalyst model for product information

=head1 SYNOPSIS

    package MyApp::Model::Products;
    use base 'Mango::Catalyst::Model::Products';

=head1 DESCRIPTION

Mango::Catalyst::Model::Products provides glue between
Mango::Provider::Products and Catalyst models. If you would like to use a
different provider, simply set C<provider_class>:

    __PACKAGE__->provider_class('OtherProductProvider');

See the classes below for more information about configuring your models.

=head1 SEE ALSO

L<Mango::Catalyst::Model::Provider>, L<Mango::Provider::Products>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
