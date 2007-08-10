#!perl -w
# $Id$
use strict;
use warnings;
use utf8;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 71;
    use Mango::Test::Catalyst;

    use_ok('Mango::Catalyst::Plugin::I18N');
};


## get the language(s) and localize a matched language
{
    my $c = Mango::Test::Catalyst->new({
        request => {
            'Accept-Language' => 'en-us,en;q=0.5'
        }
    });

    Mango::Catalyst::Plugin::I18N::setup($c);

    is($c->{'languages'}, undef);

    my $languages = Mango::Catalyst::Plugin::I18N::languages($c);
    is(scalar @{$languages}, 3);
    is($languages->[0], 'en-us');
    is($languages->[1], 'en');
    is($languages->[2], 'i-default');    
    is_deeply($c->{'languages'}, [qw/en-us en i-default/]);
    is(Mango::Catalyst::Plugin::I18N::language($c), 'en');
    is($c->localize('Language'), 'English');
};


## get the language(s) and localize without matches
{
    my $c = Mango::Test::Catalyst->new({
        request => {
            'Accept-Language' => 'ba;q=0.5'
        }
    });

    Mango::Catalyst::Plugin::I18N::setup($c);

    is($c->{'languages'}, undef);

    my $languages = Mango::Catalyst::Plugin::I18N::languages($c);
    is(scalar @{$languages}, 2);
    is($languages->[0], 'ba');
    is($languages->[1], 'i-default');    
    is_deeply($c->{'languages'}, [qw/ba i-default/]);
    is(Mango::Catalyst::Plugin::I18N::language($c), 'en');
    is($c->localize('Language'), 'English');
};


## get the language(s) and localize with foreign match
{
    my $c = Mango::Test::Catalyst->new({
        request => {
            'Accept-Language' => 'ru,en-us,en;q=0.5'
        }
    });

    Mango::Catalyst::Plugin::I18N::setup($c);
    local $c->config->{'i18n_class'} = undef;

    is($c->{'languages'}, undef);

    my $languages = Mango::Catalyst::Plugin::I18N::languages($c);
    is(scalar @{$languages}, 4);
    is($languages->[0], 'ru');
    is($languages->[1], 'en-us');
    is($languages->[2], 'en');
    is($languages->[3], 'i-default');    
    is_deeply($c->{'languages'}, [qw/ru en-us en i-default/]);
    is(Mango::Catalyst::Plugin::I18N::language($c), 'ru');
    is($c->localize('Language'), 'русском');
};


## manually set langage(s)
{
    my $c = Mango::Test::Catalyst->new;

    my $languages = Mango::Catalyst::Plugin::I18N::languages($c, 'ru, ra');
    is(scalar @{$languages}, 2);
    is($languages->[0], 'ru');
    is($languages->[1], 'ra');

    $languages = Mango::Catalyst::Plugin::I18N::languages($c, [qw/tz es/]);
    is(scalar @{$languages}, 2);
    is($languages->[0], 'tz');
    is($languages->[1], 'es');

    my $language = Mango::Catalyst::Plugin::I18N::language($c, 'ru');
    is($language, 'ru');
};


## test i18_class
{
    my $c = Mango::Test::Catalyst->new({
        config => {
            i18n_class => 'Mango::Test::I18N'
        },
        request => {
            'Accept-Language' => 'en-us,en;q=0.5'
        }
    });

    Mango::Catalyst::Plugin::I18N::setup($c);

    is($c->{'languages'}, undef);

    my $languages = Mango::Catalyst::Plugin::I18N::languages($c);
    is(scalar @{$languages}, 3);
    is($languages->[0], 'en-us');
    is($languages->[1], 'en');
    is($languages->[2], 'i-default');    
    is_deeply($c->{'languages'}, [qw/en-us en i-default/]);
    is(Mango::Catalyst::Plugin::I18N::language($c), 'en');
    is($c->localize('Language'), 'Test English Language');

    ## pass unchanged through Mango::I18N
    is($c->localize('RESOURCE_NOT_FOUND'), 'Resource Not Found');
};


## test $appname::I18N class
{
    my $c = Mango::Test::Catalyst->new({
        request => {
            'Accept-Language' => 'en-us,en;q=0.5'
        }
    });

    Mango::Catalyst::Plugin::I18N::setup($c);

    is($c->{'languages'}, undef);

    my $languages = Mango::Catalyst::Plugin::I18N::languages($c);
    is(scalar @{$languages}, 3);
    is($languages->[0], 'en-us');
    is($languages->[1], 'en');
    is($languages->[2], 'i-default');    
    is_deeply($c->{'languages'}, [qw/en-us en i-default/]);
    is(Mango::Catalyst::Plugin::I18N::language($c), 'en');
    is($c->localize('Test'), 'Test Catalyst I18N English Language');

    ## pass unchanged through Mango::I18N
    is($c->localize('RESOURCE_NOT_FOUND'), 'Resource Not Found');

    ## reuse handle
    local $c->request->{'Accept-Language'} = 'ru;q=0.5';
    is($c->localize('RESOURCE_NOT_FOUND'), 'Resource Not Found');
};


## test $appname::L10N class
SKIP: {
    skip 'Test::Without::Module not installed', 20 unless eval 'require Test::Without::Module';
    
    ## I18N is bad, use L10N
    Test::Without::Module->import('Mango::Test::Catalyst::I18N');
    my $c = Mango::Test::Catalyst->new({
        request => {
            'Accept-Language' => 'en-us,en;q=0.5'
        }
    });

    Mango::Catalyst::Plugin::I18N::setup($c);

    is($c->{'languages'}, undef);

    my $languages = Mango::Catalyst::Plugin::I18N::languages($c);
    is(scalar @{$languages}, 3);
    is($languages->[0], 'en-us');
    is($languages->[1], 'en');
    is($languages->[2], 'i-default');    
    is_deeply($c->{'languages'}, [qw/en-us en i-default/]);
    is(Mango::Catalyst::Plugin::I18N::language($c), 'en');
    is($c->localize('Test'), 'Test Catalyst L10N English Language');

    ## pass unchanged through Mango::I18N
    is($c->localize('RESOURCE_NOT_FOUND'), 'Resource Not Found');

    ## reuse handle
    local $c->request->{'Accept-Language'} = 'ru;q=0.5';
    is($c->localize('RESOURCE_NOT_FOUND'), 'Resource Not Found');


    ## I18N and L10N are bad
    Test::Without::Module->import('Mango::Test::Catalyst::L10N');
    $c = Mango::Test::Catalyst->new({
        request => {
            'Accept-Language' => 'en-us,en;q=0.5'
        }
    });

    Mango::Catalyst::Plugin::I18N::setup($c);

    is($c->{'languages'}, undef);

    $languages = Mango::Catalyst::Plugin::I18N::languages($c);
    is(scalar @{$languages}, 3);
    is($languages->[0], 'en-us');
    is($languages->[1], 'en');
    is($languages->[2], 'i-default');    
    is_deeply($c->{'languages'}, [qw/en-us en i-default/]);
    is(Mango::Catalyst::Plugin::I18N::language($c), 'en');
    is($c->localize('Test'), 'Test');

    ## pass unchanged through Mango::I18N
    is($c->localize('RESOURCE_NOT_FOUND'), 'Resource Not Found');

    ## reuse handle
    local $c->request->{'Accept-Language'} = 'ru;q=0.5';
    is($c->localize('RESOURCE_NOT_FOUND'), 'Resource Not Found');
};
