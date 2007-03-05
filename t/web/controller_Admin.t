use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Mango::Web' }
BEGIN { use_ok 'Mango::Web::Controller::Admin' }

ok( request('/admin')->is_success, 'Request should succeed' );


