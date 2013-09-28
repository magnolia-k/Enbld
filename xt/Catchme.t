#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

BEGIN {

    use_ok( 'Enbld::Catchme' );

};

require Enbld::Error;

eval {
    die Enbld::Error->new( "Exception Raised" );
};

catchme 'Enbld::Error' => sub {
    like( $@, qr/Exception Raised/, 'catch exception' );
};

done_testing();
