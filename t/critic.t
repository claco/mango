#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Test::More;

    plan skip_all => 'set TEST_AUTHOR to enable this test' unless $ENV{TEST_AUTHOR};
    plan skip_all => 'Disabled during conversion';

    eval 'use Test::Perl::Critic 1.01';
    plan skip_all => 'Test::Perl::Critic 1.01 not installed' if $@;

    eval 'use Perl::Critic 1.051';
    plan skip_all => 'Perl::Critic 1.051 not installed' if $@;
};

Test::Perl::Critic->import(
    -profile  => 't/critic.rc',
    -severity => 1,
    -format   => "%m at line %l, column %c: %p Severity %s\n\t%r"
);

my @files = Test::Perl::Critic::all_code_files('lib');

BAIL_OUT('No code files were found') unless scalar @files;

plan tests => scalar @files;
for my $file (@files) {
    critic_ok($file, $file);
};
