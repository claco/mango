#!perl -wT
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test;

    eval 'require DBD::SQLite';
    if($@) {
        plan skip_all => 'DBD::SQLite not installed';
    } else {
        plan tests => 15;
    };

    use_ok('Mango::Provider');
    use_ok('Mango::Exception', ':try');
};

my $schema = Mango::Test->init_schema;
my $provider = Mango::Provider->new({
    result_class => 'Mango::Cart'
});

isa_ok($provider, 'Mango::Provider');
is($provider->result_class, 'Mango::Cart');


$provider->setup([
    result_class => 'Mango::Order'
]);
is($provider->result_class, 'Mango::Cart');


## create type not implemented
{
    try {
        local $ENV{'LANG'} = 'en';
        $provider->create;

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/overriden/i, 'must be overriden');
    } otherwise {
        fail('Other exception thrown');
    };
};


## delete type not implemented
{
    try {
        local $ENV{'LANG'} = 'en';
        $provider->delete;

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/overriden/i, 'must be overriden');
    } otherwise {
        fail('Other exception thrown');
    };
};


## search type not implemented
{
    try {
        local $ENV{'LANG'} = 'en';
        $provider->search;

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/overriden/i, 'must be overriden');
    } otherwise {
        fail('Other exception thrown');
    };
};


## update type not implemented
{
    try {
        local $ENV{'LANG'} = 'en';
        $provider->update;

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/overriden/i, 'must be overriden');
    } otherwise {
        fail('Other exception thrown');
    };
};


## set_component_class goes boom if class can't be loaded
{
    try {
        local $ENV{'LANG'} = 'en';
        $provider->result_class('Foo');

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/loaded/i, 'class cant be loaded');
    } otherwise {
        fail('Other exception thrown');
    };
};