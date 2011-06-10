#!/usr/bin/perl

use strict;

BEGIN {
	$^W = 1;
}
use Test::More tests => 34;
use Test::Exception;

require PPIx::EditorTools;
my $pet_obj = new_ok('PPIx::EditorTools');

my @subs =
	qw( new code ppi process_doc find_unmatched_brace get_all_variable_declarations element_depth find_token_at_location find_variable_declaration );
use_ok( 'PPIx::EditorTools', @subs );

foreach my $subs (@subs) {
	can_ok( 'PPIx::EditorTools', $subs );
}

#TODO need more pkg tests
#######
# Testing PPIx::EditorTools->process_doc()
#######
# Check that something died - we do not care why
dies_ok { PPIx::EditorTools->process_doc() } 'expecting PPIx::EditorTools->process_doc() to die';

# check code to ppi
my @test_files = (
	{ filename => 't/outline/Foo.pm', },
	{ filename => 't/outline/file1.pl', },
	{ filename => 't/outline/file2.pl', },
	{ filename => 't/outline/Mooclass.pm', },
	{ filename => 't/outline/Moorole.pm', },
	{ filename => 't/outline/Moofirst.pm', },
);
my $obj = PPIx::EditorTools->new();
$obj->ppi(undef);
$obj->code(undef);
foreach my $file (@test_files) {
	my $code;
	if ( $file->{filename} ) {
		open my $file_handle, '<', $file->{filename} or die "Could not open '$file->{filename}' $!";
		local $/ = undef;
		$code = <$file_handle>;
	}
	ok( $obj->process_doc( code => $code ),
		"process_doc(code) from $file->{filename}"
	);
}

## check ppi source
my %ppi = (
	'attributes' => [
		{   'line' => 7,
			'name' => 'balance',
		},
		{   'line' => 13,
			'name' => 'overdraft',
		},
		{   'line' => 23,
			'name' => 'name',
		},
		{   'line' => 25,
			'name' => 'account',
		},
	],
	'line'    => 3,
	'methods' => [
		{   'line' => 27,
			'name' => '_build_overdraft',
		},
	],
	'modules' => [
		{   'line' => 1,
			'name' => 'MooseX::Declare',
		},
	],
	'name'     => 'Moofirst',
	'pragmata' => [
		{   'line' => 5,
			'name' => 'version',
		},
	],
);

$obj->ppi('PPI::Document');
$obj->code(undef);
ok( $obj->process_doc(%ppi), 'process_doc(ppi)' );
## check neither ppi or code fails
$obj->ppi(undef);
$obj->code(undef);
my %case = ( one => 'ppi', two => 'code', three => 'PPI::Document', );
throws_ok { $obj->process_doc(%case) } '/arguments ppi or code required/', 'arguments ppi or code required';

#TODO add more tests
dies_ok { PPIx::EditorTools->find_unmatched_brace() } 'expecting PPIx::EditorTools->find_unmatched_brace() to die';

#TODO add more tests
dies_ok { PPIx::EditorTools->get_all_variable_declarations() }
'expecting PPIx::EditorTools->get_all_variable_declarations() to die';

#TODO add more tests
dies_ok { PPIx::EditorTools->element_depth() } 'expecting PPIx::EditorTools->element_depth() to die';

#TODO add more tests
dies_ok { PPIx::EditorTools->find_token_at_location() } 'expecting PPIx::EditorTools->find_token_at_location() to die';

#dies_ok { PPIx::EditorTools->find_variable_declaration() } 'expecting PPIx::EditorTools->find_variable_declaration() to die';
######
# let's check our lib's are here.
######
my $test_object;
require PPIx::EditorTools::FindUnmatchedBrace;
$test_object = new_ok('PPIx::EditorTools::FindUnmatchedBrace');

require PPIx::EditorTools::FindVariableDeclaration;
$test_object = new_ok('PPIx::EditorTools::FindVariableDeclaration');

require PPIx::EditorTools::IntroduceTemporaryVariable;
$test_object = new_ok('PPIx::EditorTools::IntroduceTemporaryVariable');

require PPIx::EditorTools::RenamePackage;
$test_object = new_ok('PPIx::EditorTools::RenamePackage');

require PPIx::EditorTools::RenamePackageFromPath;
$test_object = new_ok('PPIx::EditorTools::RenamePackageFromPath');

require PPIx::EditorTools::RenameVariable;
$test_object = new_ok('PPIx::EditorTools::RenameVariable');

require PPIx::EditorTools::FindUnmatchedBrace;
$test_object = new_ok('PPIx::EditorTools::FindUnmatchedBrace');

require PPIx::EditorTools::Outline;
$test_object = new_ok('PPIx::EditorTools::Outline');

require PPIx::EditorTools::Lexer;
$test_object = new_ok('PPIx::EditorTools::Lexer');

require PPIx::EditorTools::ReturnObject;
$test_object = new_ok('PPIx::EditorTools::ReturnObject');

done_testing();

#done_testing($number_of_tests);
