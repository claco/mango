# $Id$
package Catalyst::Plugin::Authentication::Mango;
use strict;
use warnings;
our $VERSION = $Mango::VERSION;

BEGIN {
    use base qw/Catalyst::Plugin::Authentication/;
    use Mango ();
};

sub user {
    my $c = shift;

    return $c->NEXT::user(@_) || $c->default_auth_store->get_anonymous_user(@_);
}

1;
__END__
