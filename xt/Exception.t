#!/usr/bin/perl

use 5.012;
use warnings;

use Carp;

use Test::More;

require_ok( 'Enbld::Exception' );

eval {
    croak Enbld::Exception->new( 'exception message' );
};

like( $@, qr/ABORT:exception message/, 'captured exception' );

my $param = {
    param   =>  'parameter',
};

eval {
    croak Enbld::Exception->new( 'exception message with parameter', $param );
};

like( $@, qr/ABORT:exception message with parameter/,
        'exception with parameter captured' );

done_testing();
