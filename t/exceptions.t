#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 9;

    use_ok('Mango::Exception', ':try');
};


## use Error style args
{
    try {
        local $ENV{'LANG'} = 'en';

        throw Mango::Exception(
            -text => 'Foo'
        );

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/foo/i, 'got -text');
    } otherwise {
        fail('Other exception thrown');
    };
};


## use Error style args without -text
{
    try {
        local $ENV{'LANG'} = 'en';

        throw Mango::Exception(
            -line => 44
        );

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/unhandled error/i, 'got default');
    } otherwise {
        fail('Other exception thrown');
    };
};


## pass params to Maketext
{
    try {
        local $ENV{'LANG'} = 'en';

        throw Mango::Exception('SCHEMA_SOURCE_NOT_FOUND', 'Foo');

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/foo not found/i, 'got params');
    } otherwise {
        fail('Other exception thrown');
    };
};


## get unhandled message
{
    try {
        local $ENV{'LANG'} = 'en';

        throw Mango::Exception;

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/unhandled error/i, 'got params');
    } otherwise {
        fail('Other exception thrown');
    };
};
