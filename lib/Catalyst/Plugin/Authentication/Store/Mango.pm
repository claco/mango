package Catalyst::Plugin::Authentication::Store::Mango;
use strict;
use warnings;
our $VERSION = '0.01';

BEGIN {
    use Catalyst::Plugin::Authentication::Store::Mango::Backend;
};

sub setup {
    my $c = shift;

    $c->default_auth_store(
        Catalyst::Plugin::Authentication::Store::Mango::Backend->new
    );

	return $c->NEXT::setup(@_);
};

1;
__END__
