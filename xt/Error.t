#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require_ok( 'Blender::Error' );

local $@;
is( Blender::Error->caught, undef, "error isn't captured" );

eval {
    die Blender::Error->new( 'error message' );
};

ok( Blender::Error->caught, 'error captured' );
is( $@, "ERROR:error message\n", 'captured message' );

done_testing();
