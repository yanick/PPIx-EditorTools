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
			[   'keyword',
				1,
				1,
				3
			],
			[   'Whitespace',
				1,
				4,
				1
			],
			[   'pragma',
				1,
				5,
				6
			],
			[   'Structure',
				1,
				11,
				1
			],
			[   'Whitespace',
				1,
				12,
				1
			],
			[   'keyword',
				1,
				13,
				3
			],
			[   'Whitespace',
				1,
				16,
				1
			],
			[   'pragma',
				1,
				17,
				8
			],
			[   'Structure',
				1,
				25,
				1
			],
			[   'Whitespace',
				1,
				26,
				1
			],
			[   'keyword',
				2,
				1,
				3
			],
			[   'Whitespace',
				2,
				4,
				1
			],
			[   'Word',
				2,
				5,
				3
			],
			[   'Structure',
				2,
				8,
				1
			],
			[   'Whitespace',
				2,
				9,
				1
			],
			[   'Whitespace',
				3,
				1,
				1
			],
			[   'keyword',
				4,
				1,
				2
			],
			[   'Whitespace',
				4,
				3,
				1
			],
			[   'Symbol',
				4,
				4,
				7
			],
			[   'Whitespace',
				4,
				11,
				1
			],
			[   'Operator',
				4,
				12,
				1
			],
			[   'Whitespace',
				4,
				13,
				1
			],
			[   'Number',
				4,
				14,
				2
			],
			[   'Structure',
				4,
				16,
				1
			],
			[   'Whitespace',
				4,
				17,
				1
			],
			[   'Whitespace',
				5,
				1,
				1
			],
			[   'keyword',
				6,
				1,
				3
			],
			[   'Whitespace',
				6,
				4,
				1
			],
			[   'Word',
				6,
				5,
				4
			],
			[   'Whitespace',
				6,
				9,
				1
			],
			[   'Structure',
				6,
				10,
				1
			],
			[   'Whitespace',
				6,
				11,
				1
			],
			[   'Structure',
				7,
				1,
				1
			],
			[   'Whitespace',
				7,
				2,
				1
			],
			[   'Whitespace',
				8,
				1,
				1
			],
		],
	},
);

plan tests => @cases * 1;

use PPIx::EditorTools::Lexer;

my @result;
foreach my $c (@cases) {
	@result = ();
	PPIx::EditorTools::Lexer->new->lexer( code => $c->{code}, highlighter => \&highlighter );

	#diag explain @result;
	is_deeply \@result, $c->{expected};
}

sub highlighter {
	push @result, [@_];
}



