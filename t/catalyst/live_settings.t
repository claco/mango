#!perl -w
# $Id$
use strict;
use warnings;

use lib 't/lib';
use Mango::Tests::Catalyst::Settings;
Mango::Tests::Catalyst::Settings->runtests;
