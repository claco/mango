#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 7;
    use Mango::Test::Catalyst;

    use_ok('Mango::Catalyst::Plugin::I18N');
};

my $c = Mango::Test::Catalyst->context;


## get the languages
{
    local $c->config->{'request'}->{'Accept-Language'} = 'en-us,en;q=0.5';

    is($c->{'languages'}, undef);

    my $languages = Mango::Catalyst::Plugin::I18N::languages($c);
    is(scalar @{$languages}, 3);
    is($languages->[0], 'en-us');
    is($languages->[1], 'en');
    is($languages->[2], 'i-default');    
    is_deeply($c->{'languages'}, [qw/en-us en i-default/]);
};