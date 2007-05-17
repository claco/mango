# $Id$
package Mango::Catalyst::Model::Users;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Model::Provider/;
};

__PACKAGE__->config(
    provider_class => 'Mango::Provider::Users'
);

1;
__END__

=head1 NAME

Mango::Catalyst::Model::Users - Catalyst model for user information

=head1 DESCRIPTION

Mango::Catalyst::Model::Users provides glue between Mango::Provider::Users
and Catalyst models. If you would like to use a different provider, simply set
C<provider_class>:

    __PACKAGE__->provider_class('OtherUserProvider');

See the classes below for more information about configuring your models.

=head1 SEE ALSO

L<Mango::Catalyst::Model::Provider>, L<Mango::Provider::Users>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
