#!perl -w
# $Id$
use strict;
use warnings;

use lib 't/lib';
use Mango::Tests::Catalyst::Admin::Products;
Mango::Tests::Catalyst::Admin::Products->runtests;
