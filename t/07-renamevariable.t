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

plan tests => 9;

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


# tests for camel casing
$code = <<'END_CODE';
sub foo {
    my $x_var = 1;

    print "Do stuff with ${x_var}\n";
    $x_var += 1;

    my $_someVariable = 2;
    $_someVariable++;
}
END_CODE

my $xvar_replacement = $code;
$xvar_replacement =~ s/x_var/xVar/g; # yes, this is simple

eq_or_diff(
    PPIx::EditorTools::RenameVariable->new->rename(
        code          => $code,
        line          => 2,
        column        => 8,
        to_camel_case => 1,
      )->code,
    $xvar_replacement,
    'camelCase xVar'
);

$xvar_replacement =~ s/x_?var/XVar/gi; # yes, this is simple

eq_or_diff(
    PPIx::EditorTools::RenameVariable->new->rename(
        code          => $code,
        line          => 2,
        column        => 8,
        to_camel_case => 1,
        'ucfirst'     => 1,
      )->code,
    $xvar_replacement,
    'camelCase xVar (ucfirst)'
);


my $yvar_replacement= $code;
$yvar_replacement =~ s/_someVariable/_some_variable/g;

eq_or_diff(
    PPIx::EditorTools::RenameVariable->new->rename(
        code            => $code,
        line            => 7,
        column          => 8,
        from_camel_case => 1,
      )->code,
    $yvar_replacement,
    'from camelCase _some_variable'
);

$yvar_replacement =~ s/_some_variable/_Some_Variable/g;

eq_or_diff(
    PPIx::EditorTools::RenameVariable->new->rename(
        code            => $code,
        line            => 7,
        column          => 8,
        from_camel_case => 1,
        'ucfirst'       => 1
      )->code,
    $yvar_replacement,
    'from camelCase _some_variable (ucfirst)'
);

