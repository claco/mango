#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use lib 't/var/TestApp/lib';
    use Mango::Test tests => 15;
    use Cwd;
    use File::Path;
    use File::Spec::Functions qw/catfile/;
    use YAML;

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

    rmtree($app);
    $helper->mk_app($app);

    my $config = YAML::LoadFile(catfile($app, 'testapp.yml'));
    $config->{'connection_info'}->[0] = 'dbi:SQLite:t/var/TestApp/data/mango.db';
    YAML::DumpFile(catfile($app, 'testapp.yml'), $config);

    chdir('..');
    chdir('..');

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
    diag $r->content;

    ## using Content-Type header
    $m->add_header('Content-Type', 'text/x-yaml');
    $r = $m->get('/users/');
    is($r->code, 400);
    is($r->header('Content-Type'), 'text/x-yaml');
    diag $r->content;
};
