#!perl -w
# $Id$
use strict;
use warnings;

use lib 't/lib';
use Mango::Tests::Catalyst::Users;
Mango::Tests::Catalyst::Users->runtests;
