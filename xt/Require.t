#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require_ok( 'Blender::Require' );

eval { Blender::Require->try_require; };
like( $@, qr/ABORT:'Blender::Require' requires module name/, 'empty name' );

eval { Blender::Require->try_require( 'Blender::Dummy' ); };
like( $@, qr/ERROR:Can't load module:Blender::Dummy/, 'dummy name' );

is( Blender::Require->try_require( 'Blender::Declare' ), 'Blender::Declare',
        'valid name' );

done_testing();
