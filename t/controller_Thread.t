use strict;
use warnings;
use Test::More;


use Catalyst::Test 'forum';
use forum::Controller::Thread;

ok( request('/thread')->is_success, 'Request should succeed' );
done_testing();
