#!perl -w
# $Id: /local/CPAN/Mango/t/catalyst/live_cart.t 1528 2008-04-14T01:08:40.114508Z claco  $
use strict;
use warnings;

use lib 't/lib';
use Mango::Tests::Catalyst::Cart::Path;
Mango::Tests::Catalyst::Cart::Path->runtests;
