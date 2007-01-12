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

    $c->config->{authentication}{mango}{model} ||= 'Users';
    $c->config->{authentication}{mango}{user_field} ||= 'username';
    $c->config->{authentication}{mango}{password_field} ||= 'password';
    $c->config->{authentication}{mango}{password_type} ||= 'clear';
    $c->config->{authorization}{mango}{roles_field} ||= 'roles';
    $c->config->{authorization}{mango}{role_name_field} ||= 'name';

    $c->default_auth_store(
        Catalyst::Plugin::Authentication::Store::Mango::Backend->new({
            auth  => $c->config->{authentication}{mango},
            authz => $c->config->{authorization}{mango}
        })
    );

	$c->NEXT::setup(@_);
};

sub prepare {
    my $c = shift->NEXT::prepare(@_);

    $c->default_auth_store->model(
        $c->model($c->config->{authentication}{mango}{model})
    ) unless $c->default_auth_store->model;

    $c->default_auth_store->context($c);

    return $c;
};

1;
__END__
