# $Id$
package Mango::Catalyst::Model::Wishlists;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Model::Provider/;
}

__PACKAGE__->config( provider_class => 'Mango::Provider::Wishlists' );

1;
__END__

=head1 NAME

Mango::Catalyst::Model::Wishlists - Catalyst model for wishlist information

=head1 SYNOPSIS

    package MyApp::Model::Wishlists;
    use base 'Mango::Catalyst::Model::Wishlists';

=head1 DESCRIPTION

Mango::Catalyst::Model::Wishlists provides glue between
Mango::Provider::Wishlists and Catalyst models. If you would like to use a
different provider, simply set C<provider_class>:

    __PACKAGE__->provider_class('OtherWishlistProvider');

See the classes below for more information about configuring your models.

=head1 SEE ALSO

L<Mango::Catalyst::Model::Provider>, L<Mango::Provider::Wishlists>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
