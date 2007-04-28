# $Id$
package Mango::Catalyst::Plugin::Authentication;
use strict;
use warnings;
our $VERSION = $Mango::VERSION;

BEGIN {
    use base qw/Catalyst::Plugin::Authentication/;

    use Mango ();
    use Mango::Catalyst::Plugin::Authentication::AnonymousUser ();
};

sub user {
    my $c = shift;
    my $config = $c->config->{'authentication'}{'realms'}{'mango'}{'store'};

    return $c->NEXT::user(@_) || Mango::Catalyst::Plugin::Authentication::AnonymousUser->new($c, $config, @_);
};

1;
__END__
