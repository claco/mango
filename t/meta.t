#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Test::More;

    plan skip_all => 'set TEST_AUTHOR to enable this test' unless $ENV{TEST_AUTHOR};
    plan skip_all => 'run make manifest to generate META.yml' unless -e 'META.yml';

    eval 'use Test::YAML::Meta';
    plan skip_all => 'Test::YAML::Meta not installed' if $@;
};

meta_yaml_ok();
