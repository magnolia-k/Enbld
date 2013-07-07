#!/usr/bin/perl
use 5.012;
use warnings;

use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Blender::Declare' ) || print "Bail out!\n";
}

diag( "Testing Blender::Declare $Blender::Declare::VERSION, Perl $], $^X" );
