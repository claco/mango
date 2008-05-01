#!perl -w
# $Id$
use strict;
use warnings;

use lib 't/lib';
use Mango::Tests::Catalyst::Cart;
Mango::Tests::Catalyst::Cart->runtests;
