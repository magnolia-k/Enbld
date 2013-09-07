#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require_ok( 'Blender::Error' );

eval {
    die Blender::Error->new( 'error message' );
};

is( $@, "ERROR:error message\n", 'captured message' );

done_testing();
