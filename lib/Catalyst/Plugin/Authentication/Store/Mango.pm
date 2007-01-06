# $Id$
package Catalyst::Plugin::Authentication::Store::Mango;
use strict;
use warnings;
our $VERSION = '0.01';

BEGIN {
    use Catalyst::Plugin::Authentication::Store::Mango::Backend;
};

sub setup {
    my $c = shift;
    $c->config->{authentication}{mango}{model} ||= 'User';

    $c->default_auth_store(
        Catalyst::Plugin::Authentication::Store::Mango::Backend->new
    );

	$c->NEXT::setup(@_);
};

sub prepare {
    my $c = shift->NEXT::prepare(@_);

    $c->default_auth_store->model(
        $c->model($c->config->{authentication}{mango}{model})
    );

    return $c;
};

1;
__END__
