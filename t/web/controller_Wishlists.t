use Test::More tests => 3;
use strict;
use warnings;

use_ok('Catalyst::Test', 'Mango::Web');
use_ok('Mango::Web::Controller::Wishlists');

ok(request('/wishlists')->is_success, 'Request should succeed');
