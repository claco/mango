# $Id$
package Mango::Catalyst::Model::Orders;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Model::Provider/;
}

__PACKAGE__->config( provider_class => 'Mango::Provider::Orders' );

1;
__END__

=head1 NAME

Mango::Catalyst::Model::Orders - Catalyst model for order information

=head1 SYNOPSIS

    package MyApp::Model::Orders;
    use base 'Mango::Catalyst::Model::Orders';

=head1 DESCRIPTION

Mango::Catalyst::Model::Orders provides glue between Mango::Provider::Orders
and Catalyst models. If you would like to use a different provider, simply set
C<provider_class>:

    __PACKAGE__->provider_class('OtherOrderProvider');

See the classes below for more information about configuring your models.

=head1 SEE ALSO

L<Mango::Catalyst::Model::Provider>, L<Mango::Provider::Orders>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
