use strict;
use warnings;
use Test::More;


use Catalyst::Test 'forum';
use forum::Controller::Topic;

ok( request('/topic')->is_success, 'Request should succeed' );
done_testing();
