#!/usr/bin/perl

use 5.012;
use warnings;

use FindBin;
use lib "$FindBin::Bin/./testlib/";

use Test::More;

require_ok( 'Enbld::Definition' );

my $def = Enbld::Definition->new( 'dummy' );
isa_ok( $def, 'Enbld::Definition::Dummy' );

done_testing();
