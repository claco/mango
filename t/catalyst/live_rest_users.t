#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use lib 'TestApp/lib';
    use Mango::Test tests => 15;
    use Cwd;
    use File::Path;
    use File::Spec::Functions;

    use_ok('Catalyst::Helper::Mango');
    use_ok('Mango::Exception', ':try');

    $ENV{'CATALYST_DEBUG'} = 0;
};


## create test app
{
    my $helper = Catalyst::Helper::Mango->new;
    my $app = 'TestApp';
    
    ## setup var
    chdir('t');
    mkdir('var') unless -d 'var';
    chdir('var');
    chdir('..');
    chdir('..');

    rmtree($app);
    $helper->mk_app($app);

    require Test::WWW::Mechanize::Catalyst;
    Test::WWW::Mechanize::Catalyst->import($app);
};


## index is only allowed in html/xhtml/text
{
    my $m = Test::WWW::Mechanize::Catalyst->new;

    ## using friendly view name
    my $r = $m->get('/users/?view=yaml');
    is($r->code, 400);
    is($r->header('Content-Type'), 'text/x-yaml');
    diag $r->content;

    ## using content-type param
    $r = $m->get('/users/?content-type=text/x-yaml');
    is($r->code, 400);
    is($r->header('Content-Type'), 'text/x-yaml');

    ## using Content-Type header
    $m->add_header('Content-Type', 'text/x-yaml');
    $r = $m->get('/users/');
    is($r->code, 400);
    is($r->header('Content-Type'), 'text/x-yaml');
};
