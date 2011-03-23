#!/usr/bin/perl

use strict;

BEGIN {
	$^W = 1;
}

use Test::More;
use Test::Differences;
use PPI;

BEGIN {
	if ( $PPI::VERSION =~ /_/ ) {
		plan skip_all => "Need released version of PPI. You have $PPI::VERSION";
		exit 0;
	}
}

my @cases = (
	{   code => <<'END_CODE',
use strict; use warnings;
use Abc;

my $global = 42;

sub qwer {
}

END_CODE
		expected => [
			{   'methods' => [
					{   'line' => 6,
						'name' => 'qwer'
					}
				],
				'modules' => [
					{   'line' => 2,
						'name' => 'Abc'
					}
				],
				'name'     => 'main',
				'pragmata' => [
					{   'line' => 1,
						'name' => 'strict'
					},
					{   'line' => 1,
						'name' => 'warnings'
					}
				]
			}
		],
	},
	{   code => <<'END_CODE',
#!/usr/bin/perl

use 5.008;
use strict;
use autodie;
use warnings FATAL => 'all';

use lib ('/opt/perl5/lib');

my $global = 42;

print "start";

sub abc {
   print 1;

   my $private = 42;

   sub def {
   }
   print 2;
}

print "ok";

sub xyz { }

print "end";

END_CODE

		expected => [
			{   'methods' => [
					{   'line' => 14,
						'name' => 'abc'
					},
					{   'line' => 19,
						'name' => 'def'
					},
					{   'line' => 26,
						'name' => 'xyz'
					}
				],
				'name'     => 'main',
				'pragmata' => [
					{   'line' => 4,
						'name' => 'strict'
					},
					{   'line' => 5,
						'name' => 'autodie'
					},
					{   'line' => 6,
						'name' => 'warnings'
					},
					{   'line' => 8,
						'name' => 'lib'
					}
				]
			}
		]
	},
);

plan tests => @cases * 1;

use PPIx::EditorTools::Outline;

foreach my $c (@cases) {
	my $outline = PPIx::EditorTools::Outline->new->find( code => $c->{code} );

	#diag explain $outline;
	is_deeply $outline, $c->{expected};
}

