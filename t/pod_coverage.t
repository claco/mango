#!perl -wT
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test;

    plan skip_all => 'set TEST_POD to enable this test' unless $ENV{TEST_POD};

    eval 'use Test::Pod::Coverage 1.04';
    plan skip_all => 'Test::Pod::Coverage 1.04' if $@;

    eval 'use Pod::Coverage 0.14';
    plan skip_all => 'Pod::Coverage 0.14 not installed' if $@;
};

my $trustme = {
    trustme =>
    [qr/^(COMPONENT|destroy|setup|create_result|type|save)$/]
};

all_pod_coverage_ok($trustme);
