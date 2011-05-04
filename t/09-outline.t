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
	{   file     => 't/outline/Foo.pm',
		expected => [
			{   'modules' => [
					{   name => 'Method::Signatures',
						line => 3,
					},
				],
				'methods' => [
					{   name => 'new',
						line => 5,
					},
					{   name => 'hello',
						line => 8,
					}
				],
				'line' => 1,
				'name' => 'Foo',
			}
		],
	},
	{   file     => 't/outline/file1.pl',
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
use strict;
END_CODE
		expected => [
			{   'pragmata' => [
					{   'line' => 1,
						name   => 'strict',
					},
				],
				'name' => 'main',
			},
		],
	},
	{   file     => 't/outline/file2.pl',
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
	my $code = $c->{code};
	if ( $c->{file} ) {
		open my $fh, '<', $c->{file} or die;
		local $/ = undef;
		$code = <$fh>;
	}
	my $outline = PPIx::EditorTools::Outline->new->find( code => $code );

	#diag explain $outline;
	is_deeply $outline, $c->{expected} or diag explain $outline;
}

