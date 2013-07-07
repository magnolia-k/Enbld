#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require_ok( 'Blender::Exception' );

local $@;
is( Blender::Exception->caught, undef, "exception isn't captured" );

use Carp;

eval {
    croak Blender::Exception->new( 'exception message' );
};

ok( Blender::Exception->caught, 'exception captured' );
like( $@, qr/ABORT:exception message/, 'captured exception' );

my $param = {
    param   =>  'parameter',
};

eval {
    croak Blender::Exception->new( 'exception message with parameter', $param );
};

like( $@, qr/ABORT:exception message with parameter/,
        'exception with parameter captured' );

done_testing();
