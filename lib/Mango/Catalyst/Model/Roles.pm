# $Id$
package Mango::Catalyst::Model::Roles;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Model::Provider/;
}

__PACKAGE__->config( provider_class => 'Mango::Provider::Roles' );

1;
__END__

=head1 NAME

Mango::Catalyst::Model::Roles - Catalyst model for user role information

=head1 SYNOPSIS

    package MyApp::Model::Roles;
    use base 'Mango::Catalyst::Model::Roles';

=head1 DESCRIPTION

Mango::Catalyst::Model::Roles provides glue between Mango::Provider::Roles
and Catalyst models. If you would like to use a different provider, simply set
C<provider_class>:

    __PACKAGE__->provider_class('OtherRoleProvider');

See the classes below for more information about configuring your models.

=head1 SEE ALSO

L<Mango::Catalyst::Model::Provider>, L<Mango::Provider::Roles>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
