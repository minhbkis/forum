use strict;
use warnings;
use Test::More;


use Catalyst::Test 'forum';
use forum::Controller::Forum;

ok( request('/forum')->is_success, 'Request should succeed' );
done_testing();
