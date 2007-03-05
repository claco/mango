use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Mango::Web' }
BEGIN { use_ok 'Mango::Web::Controller::Login' }

ok( request('/login')->is_success, 'Request should succeed' );


