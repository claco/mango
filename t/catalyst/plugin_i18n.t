#!perl -w
# $Id$
use strict;
use warnings;
use utf8;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 34;
    use Mango::Test::Catalyst;

    use_ok('Mango::Catalyst::Plugin::I18N');
};


## get the language(s) and localize a matched language
{
    my $c = Mango::Test::Catalyst->context;
    local $c->config->{'request'}->{'Accept-Language'} = 'en-us,en;q=0.5';

    Mango::Catalyst::Plugin::I18N::setup($c);

    is($c->{'languages'}, undef);

    my $languages = Mango::Catalyst::Plugin::I18N::languages($c);
    is(scalar @{$languages}, 3);
    is($languages->[0], 'en-us');
    is($languages->[1], 'en');
    is($languages->[2], 'i-default');    
    is_deeply($c->{'languages'}, [qw/en-us en i-default/]);

    $c->mock('languages', \&Mango::Catalyst::Plugin::I18N::languages);
    $c->mock('localize', \&Mango::Catalyst::Plugin::I18N::localize);

    is(Mango::Catalyst::Plugin::I18N::language($c), 'en');
    is($c->localize('Language'), 'English');
};


## get the language(s) and localize without matches
{
    my $c = Mango::Test::Catalyst->context;
    local $c->config->{'request'}->{'Accept-Language'} = 'ba;q=0.5';

    Mango::Catalyst::Plugin::I18N::setup($c);

    is($c->{'languages'}, undef);

    my $languages = Mango::Catalyst::Plugin::I18N::languages($c);
    is(scalar @{$languages}, 2);
    is($languages->[0], 'ba');
    is($languages->[1], 'i-default');    
    is_deeply($c->{'languages'}, [qw/ba i-default/]);

    $c->mock('languages', \&Mango::Catalyst::Plugin::I18N::languages);

    $c->mock('languages', \&Mango::Catalyst::Plugin::I18N::languages);
    $c->mock('localize', \&Mango::Catalyst::Plugin::I18N::localize);

    is(Mango::Catalyst::Plugin::I18N::language($c), 'en');
    is($c->localize('Language'), 'English');
};


## get the language(s) and localize with foreign match
{
    my $c = Mango::Test::Catalyst->context;
    local $c->config->{'request'}->{'Accept-Language'} = 'ru,en-us,en;q=0.5';

    Mango::Catalyst::Plugin::I18N::setup($c);

    is($c->{'languages'}, undef);

    my $languages = Mango::Catalyst::Plugin::I18N::languages($c);
    is(scalar @{$languages}, 4);
    is($languages->[0], 'ru');
    is($languages->[1], 'en-us');
    is($languages->[2], 'en');
    is($languages->[3], 'i-default');    
    is_deeply($c->{'languages'}, [qw/ru en-us en i-default/]);

    $c->mock('languages', \&Mango::Catalyst::Plugin::I18N::languages);

    $c->mock('languages', \&Mango::Catalyst::Plugin::I18N::languages);
    $c->mock('localize', \&Mango::Catalyst::Plugin::I18N::localize);

    is(Mango::Catalyst::Plugin::I18N::language($c), 'ru');
    is($c->localize('Language'), 'русском');
};


## test i18_class
{
    my $c = Mango::Test::Catalyst->context({
        config => {
            i18n_class => 'Mango::Test::I18N'
        }
    });
    local $c->config->{'request'}->{'Accept-Language'} = 'en-us,en;q=0.5';

    Mango::Catalyst::Plugin::I18N::setup($c);

    is($c->{'languages'}, undef);

    my $languages = Mango::Catalyst::Plugin::I18N::languages($c);
    is(scalar @{$languages}, 3);
    is($languages->[0], 'en-us');
    is($languages->[1], 'en');
    is($languages->[2], 'i-default');    
    is_deeply($c->{'languages'}, [qw/en-us en i-default/]);

    $c->mock('languages', \&Mango::Catalyst::Plugin::I18N::languages);
    $c->mock('localize', \&Mango::Catalyst::Plugin::I18N::localize);

    is(Mango::Catalyst::Plugin::I18N::language($c), 'en');
    is($c->localize('Language'), 'Test English Language');

    ## pass unchanged through Mango::I18N
    is($c->localize('RESOURCE_NOT_FOUND'), 'Resource Not Found');
}
