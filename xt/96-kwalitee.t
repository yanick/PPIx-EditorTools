use strict;
BEGIN {
	$^W = 1;
}
use Test::More;

# Don't run tests for installs
unless ( $ENV{AUTOMATED_TESTING} or $ENV{RELEASE_TESTING} ) {
	plan( skip_all => "Author tests not required for installation" );
}

eval { require Test::Kwalitee; };
plan( skip_all => 'Test::Kwalitee not installed; skipping' ) if $@;

Test::Kwalitee->import();
