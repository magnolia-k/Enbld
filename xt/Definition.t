#!/usr/bin/perl

use 5.012;
use warnings;

use FindBin;
use lib "$FindBin::Bin/./testlib/";

use Test::More;

require_ok( 'Blender::Definition::Dummy' );

my $def = Blender::Definition::Dummy->new;
isa_ok( $def, 'Blender::Definition::Dummy' );

done_testing();
