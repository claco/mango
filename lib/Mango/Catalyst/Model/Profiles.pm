# $Id$
package Mango::Catalyst::Model::Profiles;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Model::Provider/;
}

__PACKAGE__->config( provider_class => 'Mango::Provider::Profiles' );

1;
__END__

=head1 NAME

Mango::Catalyst::Model::Profiles - Catalyst model for user profile information

=head1 SYNOPSIS

    package MyApp::Model::Profiles;
    use base 'Mango::Catalyst::Model::Profiles';

=head1 DESCRIPTION

Mango::Catalyst::Model::Profiles provides glue between
Mango::Provider::Profiles and Catalyst models. If you would like to use a
different provider, simply set C<provider_class>:

    __PACKAGE__->provider_class('OtherProfilesProvider');

See the classes below for more information about configuring your models.

=head1 SEE ALSO

L<Mango::Catalyst::Model::Provider>, L<Mango::Provider::Profiles>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
