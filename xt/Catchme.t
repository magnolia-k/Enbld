#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

BEGIN {

    use_ok( 'Blender::Catchme' );

};

require Blender::Error;

eval {
    die Blender::Error->new( "Exception Raised" );
};

catchme 'Blender::Error' => sub {
    like( $@, qr/Exception Raised/, 'catch exception' );
};

done_testing();
