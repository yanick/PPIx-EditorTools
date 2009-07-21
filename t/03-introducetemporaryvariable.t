#!/usr/bin/perl

use strict;
BEGIN {
	$^W = 1;
}

use Test::More;
use Test::Differences;
use PPI;

BEGIN {
	if ($PPI::VERSION =~ /_/) {
		plan skip_all => "Need released version of PPI. You have $PPI::VERSION";
		exit 0;
	}
}

plan tests => 6;

use PPIx::EditorTools::IntroduceTemporaryVariable;

my $code = <<'END_CODE';
use strict; use warnings;
    my $x = ( 1 + 10 / 12 ) * 2;
    my $y = ( 3 + 10 / 12 ) * 2;
END_CODE

my $new_code = PPIx::EditorTools::IntroduceTemporaryVariable->new->introduce(
    code           => $code,
    start_location => [ 2, 19 ],    # or just character position
    end_location   => [ 2, 25 ],    # or ppi-style location
    varname        => '$foo',
);
isa_ok( $new_code,          'PPIx::EditorTools::ReturnObject' );
isa_ok( $new_code->element, 'PPI::Token' );
is_deeply( $new_code->element->location, [ 2, 5, 5 ], 'temp var location' );
eq_or_diff( $new_code->code, <<'RESULT', '10 / 12' );
use strict; use warnings;
    my $foo = 10 / 12;
    my $x = ( 1 + $foo ) * 2;
    my $y = ( 3 + $foo ) * 2;
RESULT

$new_code = PPIx::EditorTools::IntroduceTemporaryVariable->new->introduce(
    code           => $code,
    start_location => [ 2, 13 ],    # or just character position
    end_location   => [ 2, 27 ],    # or ppi-style location
    varname        => '$foo',
);

eq_or_diff( $new_code->code, <<'RESULT', '( 1 + 10 / 12 )' );
use strict; use warnings;
    my $foo = ( 1 + 10 / 12 );
    my $x = $foo * 2;
    my $y = ( 3 + 10 / 12 ) * 2;
RESULT

$code = <<'END_CODE2';
use strict; use warnings;
my $x = ( 1 + 10 
    / 12 ) * 2;
my $y = ( 3 + 10 / 12 ) * 2;
END_CODE2

$new_code = PPIx::EditorTools::IntroduceTemporaryVariable->new->introduce(
    code           => $code,
    start_location => [ 2, 9 ],     # or just character position
    end_location   => [ 3, 10 ],    # or ppi-style location
                                    # varname        => '$foo',
);
eq_or_diff( $new_code->code, <<'RESULT', '( 1 + 10 \n / 12 )' );
use strict; use warnings;
my $tmp = ( 1 + 10 
    / 12 );
my $x = $tmp * 2;
my $y = ( 3 + 10 / 12 ) * 2;
RESULT

