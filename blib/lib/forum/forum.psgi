use strict;
use warnings;

use forum;

my $app = forum->apply_default_middlewares(forum->psgi_app);
$app;

