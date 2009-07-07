#!/usr/bin/perl

use strict;
BEGIN {
	$^W = 1;
}

use Test::More tests => 6;
use Test::Differences;

use PPIx::EditorTools::FindUnmatchedBrace;

my $brace =
  PPIx::EditorTools::FindUnmatchedBrace->new->find(
    code => "package TestPackage;\nuse strict;\nuse warnings;\nsub x { 1;\n" );

isa_ok( $brace,          'PPIx::EditorTools::ReturnObject' );
isa_ok( $brace->element, 'PPI::Structure::Block' );
is_deeply( $brace->element->location, [ 4, 7, 7 ], 'unclosed sub' );

$brace =
  PPIx::EditorTools::FindUnmatchedBrace->new->find(
    code => "package TestPackage;\nfor my \$x (1..2) { 1;\n" );

isa_ok( $brace,          'PPIx::EditorTools::ReturnObject' );
isa_ok( $brace->element, 'PPI::Structure::Block' );
is_deeply( $brace->element->location, [ 2, 18, 18 ], 'unclosed for block' );
