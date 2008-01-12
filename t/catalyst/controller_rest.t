#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 16;

    use_ok('Mango::Catalyst::Controller::REST');
    use_ok('Mango::Test::Catalyst');
    use_ok('Mango::Exception', ':try');
};


## check request content type setting
{
    my $c = Mango::Test::Catalyst->new;
    my $controller = $c->controller('REST');
    isa_ok($controller, 'Mango::Catalyst::Controller::REST');

    $c->request->content_type('text/html');
    $controller->ACCEPT_CONTEXT($c);
    is($c->request->content_type, 'text/html');

    $c->request->{'view'} = 'json';
    $controller->ACCEPT_CONTEXT($c);
    is($c->request->content_type, 'text/x-json');

    $c->request->{'view'} = 'yml';
    $controller->ACCEPT_CONTEXT($c);
    is($c->request->content_type, 'text/x-yaml');

    $c->request->{'view'} = 'atom';
    $controller->ACCEPT_CONTEXT($c);
    is($c->request->content_type, 'application/atom+xml');

    $c->request->{'view'} = 'yaml';
    $controller->ACCEPT_CONTEXT($c);
    is($c->request->content_type, 'text/x-yaml');

    $c->request->{'view'} = 'txt';
    $controller->ACCEPT_CONTEXT($c);
    is($c->request->content_type, 'text/plain');

    $c->request->{'view'} = 'rss';
    $controller->ACCEPT_CONTEXT($c);
    is($c->request->content_type, 'application/rss+xml');

    $c->request->{'view'} = 'text';
    $controller->ACCEPT_CONTEXT($c);
    is($c->request->content_type, 'text/plain');

    $c->request->{'view'} = 'htm';
    $controller->ACCEPT_CONTEXT($c);
    is($c->request->content_type, 'text/html');

    $c->request->{'view'} = 'xhtml';
    $controller->ACCEPT_CONTEXT($c);
    is($c->request->content_type, 'application/xhtml+xml');

    $c->request->{'view'} = 'html';
    $controller->ACCEPT_CONTEXT($c);
    is($c->request->content_type, 'text/html');

    $c->request->content_type('application/x-storable');
    $c->request->{'view'} = 'crapiseatenintoundef';
    $controller->ACCEPT_CONTEXT($c);
    is($c->request->content_type, undef);
};
