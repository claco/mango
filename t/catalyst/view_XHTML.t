#!perl -wT
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 9;
    use Mango::Test::Catalyst;

    use_ok('Mango::Catalyst::View::XHTML');
};

my $c = Mango::Test::Catalyst->context({
    config => {
        root => 'far',
        base => 'foo',
        INCLUDE_PATH => [
            'stuff'
        ]
    }
});
my $view = $c->view('XHTML');
isa_ok($view, 'Mango::Catalyst::View::XHTML');


## check the content type header
{
    local $c->config->{'action'} = 'xhtml';

    ok($view->process($c));
    is($c->response->content_type, 'application/rss+xml; charset=utf-8');
};
