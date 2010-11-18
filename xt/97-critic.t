use strict;
BEGIN {
	$^W = 1;
}
use File::Spec;
use Test::More;

# Don't run tests for installs
unless ( $ENV{AUTOMATED_TESTING} or $ENV{RELEASE_TESTING} ) {
	plan( skip_all => "Author tests not required for installation" );
}

eval { require Test::Perl::Critic; };
plan( skip_all => ' Test::Perl::Critic required to criticise code ' ) if $@;

my $rcfile = File::Spec->catfile( 'xt', 'perlcriticrc' );
Test::Perl::Critic->import( -profile => $rcfile, -severity => 3 );
all_critic_ok();

