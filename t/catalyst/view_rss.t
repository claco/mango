#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Test::More tests => 9;

    use Mango::Test ();
    use Mango::Test::Catalyst ();
    use DateTime ();

    use_ok('Mango::Catalyst::View::RSS');
    use_ok('Mango::Exception', ':try');
};

my $c = Mango::Test::Catalyst->new;
my $view = $c->view('RSS');
isa_ok($view, 'Mango::Catalyst::View::RSS');


## throw exception when no feed data is available
{
    try {
        local $ENV{'LANG'} = 'en';

        $view->process($c);

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/no feed data/i, 'no feed data');
    } otherwise {
        fail('Other exception thrown');
    };
};


## check the content type header
{
    local $c->stash->{'entity'} = {
        language => 'en'
    };

    ok($view->process($c));

    my $feed = $c->stash->{'feed'};
    isa_ok($feed, 'XML::Feed');
    is($feed->format, 'RSS 2.0');
    is($c->response->content_type, 'application/rss+xml; charset=utf-8');
};
