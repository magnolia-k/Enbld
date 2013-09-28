#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require_ok( 'Enbld::Target::Attribute' );

eval { Enbld::Target::Attribute->new };
like( $@, qr/ABORT:'Enbld::Target::Attribute' requires name/, 'no parameter');

my $msg = qr/ABORT:Attribute 'Invalid' is invalid name/;
eval { Enbld::Target::Attribute->new( 'Invalid' ) };
like( $@, $msg, 'invalid attribute name' );

done_testing();
