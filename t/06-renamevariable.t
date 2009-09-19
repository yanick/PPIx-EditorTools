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

plan tests => 5;

use PPIx::EditorTools::RenameVariable;

my $code = <<'END_CODE';
use MooseX::Declare;

class Test {
    has a_var => ( is => 'rw', isa => 'Str' );
    has b_var => ( is => 'rw', isa => 'Str' );

    method some_method {
        my $x_var = 1;

        print "Do stuff with ${x_var}\n";
        $x_var += 1;

        my %hash;
        for my $i (1..5) {
            $hash{$i} = $x_var;
        }
    }
}
END_CODE

my $shiny_replacement = <<'SHINY_REPLACEMENT';
use MooseX::Declare;

class Test {
    has a_var => ( is => 'rw', isa => 'Str' );
    has b_var => ( is => 'rw', isa => 'Str' );

    method some_method {
        my $shiny = 1;

        print "Do stuff with ${shiny}\n";
        $shiny += 1;

        my %hash;
        for my $i (1..5) {
            $hash{$i} = $shiny;
        }
    }
}
SHINY_REPLACEMENT

eq_or_diff( eval {
    PPIx::EditorTools::RenameVariable->new->rename(
        code        => $code,
        line        => 8,
        column      => 12,
        replacement => 'shiny',
      )->code } || "",
    $shiny_replacement,
    'replace scalar'
);

eq_or_diff(
    PPIx::EditorTools::RenameVariable->new->rename(
        code        => $code,
        line        => 11,
        column      => 9,
        replacement => 'shiny',
      )->code,
    $shiny_replacement,
    'replace scalar'
);

my $stuff_replacement = <<'STUFF_REPLACEMENT';
use MooseX::Declare;

class Test {
    has a_var => ( is => 'rw', isa => 'Str' );
    has b_var => ( is => 'rw', isa => 'Str' );

    method some_method {
        my $x_var = 1;

        print "Do stuff with ${x_var}\n";
        $x_var += 1;

        my %stuff;
        for my $i (1..5) {
            $stuff{$i} = $x_var;
        }
    }
}
STUFF_REPLACEMENT

eq_or_diff(
    PPIx::EditorTools::RenameVariable->new->rename(
        code        => $code,
        line        => 15,
        column      => 13,
        replacement => 'stuff',
      )->code,
    $stuff_replacement,
    'replace hash'
);

my $munged = PPIx::EditorTools::RenameVariable->new->rename(
    code        => $code,
    line        => 15,
    column      => 13,
    replacement => 'stuff',
);

isa_ok( $munged,          'PPIx::EditorTools::ReturnObject' );
isa_ok( $munged->element, 'PPI::Token::Symbol' );

