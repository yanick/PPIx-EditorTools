#!/usr/bin/perl

use strict;
BEGIN {
	$^W = 1;
}

use Test::More tests => 3;
use Test::Differences;

use PPIx::EditorTools::FindVariableDeclaration;

my $declaration = PPIx::EditorTools::FindVariableDeclaration->new->find(
    code   => "package TestPackage;\nuse strict;\nuse warnings;\nmy \$x=1;\n\$x++;",
    line   => 5,
    column => 2,
);

isa_ok( $declaration, 'PPIx::EditorTools::ReturnObject' );
isa_ok( $declaration->element, 'PPI::Statement::Variable' );
is_deeply( $declaration->element->location, [ 4, 1, 1 ], 'simple scalar' );

