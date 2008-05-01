#!perl -w
# $Id$
use strict;
use warnings;

use lib 't/lib';
use Mango::Tests::Catalyst::Login;
Mango::Tests::Catalyst::Login->runtests;
