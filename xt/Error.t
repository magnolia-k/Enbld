#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require_ok( 'Enbld::Error' );

eval {
    die Enbld::Error->new( 'error message' );
};

is( $@, "ERROR:error message\n", 'captured message' );

done_testing();
