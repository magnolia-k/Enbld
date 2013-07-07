#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

use File::Temp;
use autodie;

require_ok( 'Blender::Logger' );

my $temp = File::Temp->newdir;

Blender::Logger->rotate( $temp );
Blender::Logger->write( 'first message to logger' );

open my $fh_first, '<', Blender::Logger->logfile();
my $log_first = ( <$fh_first> );
close $fh_first;

is( $log_first, 'first message to logger', 'write first tracelog' );

Blender::Logger->rotate( $temp );
Blender::Logger->write( 'second message to logger' );

open my $fh_second, '<', Blender::Logger->logfile();
my $log_second = ( <$fh_second> );
close $fh_second;

is( $log_second, 'second message to logger', 'write second tracelog' );

done_testing();
