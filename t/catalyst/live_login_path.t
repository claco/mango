#!perl -w
# $Id$
use strict;
use warnings;

use lib 't/lib';
use Mango::Tests::Catalyst::Login::Path;
Mango::Tests::Catalyst::Login::Path->runtests;
