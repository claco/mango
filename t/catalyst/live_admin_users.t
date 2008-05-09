#!perl -w
# $Id$
use strict;
use warnings;

use lib 't/lib';
use Mango::Tests::Catalyst::Admin::Users;
Mango::Tests::Catalyst::Admin::Users->runtests;
