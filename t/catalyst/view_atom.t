#!perl -wT
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 9;
    use Mango::Test::Catalyst;
    use DateTime;

    use_ok('Mango::Catalyst::View::Atom');
    use_ok('Mango::Exception', ':try');
};

my $c = Mango::Test::Catalyst->new;
my $view = $c->view('Atom');
isa_ok($view, 'Mango::Catalyst::View::Atom');


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
    is($feed->format, 'Atom');
    is($c->response->content_type, 'application/atom+xml; charset=utf-8');
};
