use Test::More;

# Don't run tests for installs
unless ( $ENV{AUTOMATED_TESTING} or $ENV{RELEASE_TESTING} ) {
	plan( skip_all => "Author tests not required for installation" );
}

eval "use Test::Prereq::Build";
plan skip_all => "Test::Prereq::Build required to test dependencies" if $@;
prereq_ok();
