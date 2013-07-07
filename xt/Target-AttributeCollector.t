#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require_ok( 'Blender::Target::AttributeCollector' );

my $attributes = Blender::Target::AttributeCollector->new;
eval { $attributes->Invalid };
like( $@, qr/ABORT:'Invalid' is invalid method/, 'invalid method' );

done_testing();
