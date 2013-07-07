#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require_ok( 'Blender::Target::Attribute' );

eval { Blender::Target::Attribute->new };
like( $@, qr/ABORT:'Blender::Target::Attribute' requires name/, 'no parameter');

my $msg = qr/ABORT:Attribute 'Invalid' is invalid name/;
eval { Blender::Target::Attribute->new( 'Invalid' ) };
like( $@, $msg, 'invalid attribute name' );

done_testing();
