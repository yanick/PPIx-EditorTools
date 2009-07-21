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

plan tests => 3;

use PPIx::EditorTools::FindVariableDeclaration;

my $declaration = PPIx::EditorTools::FindVariableDeclaration->new->find(
    code   => "package TestPackage;\nuse strict;\nuse warnings;\nmy \$x=1;\n\$x++;",
    line   => 5,
    column => 2,
);

isa_ok( $declaration, 'PPIx::EditorTools::ReturnObject' );
isa_ok( $declaration->element, 'PPI::Statement::Variable' );
is_deeply( $declaration->element->location, [ 4, 1, 1 ], 'simple scalar' );

