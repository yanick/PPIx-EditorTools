#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More tests => 4;

BEGIN {
    use_ok('PPIx::EditorTools::RenameVariable');
    use_ok('PPIx::EditorTools::RenamePackage');
    use_ok('PPIx::EditorTools::RenamePackageFromPath');
    use_ok('PPIx::EditorTools::FindUnmatchedBrace');
}

