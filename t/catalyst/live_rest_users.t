#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use lib 't/var/TestApp/lib';
    use Mango::Test tests => 20;
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


## GET /users
{
    my $m = Test::WWW::Mechanize::Catalyst->new;

    ## REST using friendly view name
    my $r = $m->get('/users/?view=yaml');
    is($r->code, 200);
    is($r->header('Content-Type'), 'text/x-yaml');
    is_deeply(YAML::Load($r->content), {
        users => [
            {id => 1, username => 'admin'}
        ],
        current_page => 1,
        entries_per_page => 10,
        total_entries => 1,
        first_page => 1,
        last_page => 1
    });

    ## REST using content-type param
    $r = $m->get('/users/?content-type=text/x-yaml');
    is($r->code, 200);
    is($r->header('Content-Type'), 'text/x-yaml');
    is_deeply(YAML::Load($r->content), {
        users => [
            {id => 1, username => 'admin'}
        ],
        current_page => 1,
        entries_per_page => 10,
        total_entries => 1,
        first_page => 1,
        last_page => 1
    });

    ## REST using Content-Type header
    $m->add_header('Content-Type', 'text/x-yaml');
    $r = $m->get('/users/');
    is($r->code, 200);
    is($r->header('Content-Type'), 'text/x-yaml');
    is_deeply(YAML::Load($r->content), {
        users => [
            {id => 1, username => 'admin'}
        ],
        current_page => 1,
        entries_per_page => 10,
        total_entries => 1,
        first_page => 1,
        last_page => 1
    });
};


## POST /users
{
    my $m = Test::WWW::Mechanize::Catalyst->new;

    ## access denied for anonymous users using view
    my $r = $m->post('/users/?view=yaml');
    is($r->code, 401);
    is($r->header('Content-Type'), 'text/x-yaml');
    is($r->content, YAML::Dump(undef));

    ## access denied for anonymous users using view
    $r = $m->post('/users/?content-type=text/x-yaml');
    is($r->code, 401);
    is($r->header('Content-Type'), 'text/x-yaml');
    is($r->content, YAML::Dump(undef));

    ## access denied for anonymous users using Content-Type
    $m->add_header('Content-Type', 'text/x-yaml');
    $r = $m->post('/users/');
    is($r->code, 401);
    is($r->header('Content-Type'), 'text/x-yaml');
    is($r->content, YAML::Dump(undef));
};




