#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test;
    use Mango::Test::Catalyst;

    eval 'require Directory::Scratch';
    if($@) {
        plan skip_all => 'Directory::Scratch not installed';
    } else {
        plan tests => 5;
    };

    use_ok('Mango::Catalyst::View::Text');
};

my $temp = Directory::Scratch->new;
my $dir  = $temp->base;
my $file = $temp->touch('default', 'foo');

my $c = Mango::Test::Catalyst->context({
    config => {
        root => $dir->stringify
    },
    stash => {
        template => $file->basename
    }
});
my $view = $c->view('Text');
isa_ok($view, 'Mango::Catalyst::View::Text');


## check the content type header
{
    ok($view->process($c));
    is($c->response->content_type, 'text/plain; charset=utf-8');

    SKIP: {
        skip 'Test::LongString not installed', 1 unless eval 'require Test::LongString';

        Test::LongString::is_string_nows($c->response->body, 'foo');
    };
};
