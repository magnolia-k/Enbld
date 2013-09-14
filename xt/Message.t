#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

use File::Temp;
use autodie;

our $skip_test;

BEGIN {

    unless ( eval "use Test::Output; 1" ) {
        $skip_test++;
    }

};

require Blender::Logger;

require_ok( 'Blender::Message' );

SKIP: {
          skip "Skip message test because none of Test::Output.",
               3 if $skip_test;

    stdout_is { Blender::Message->notify( 'message' ) } '', 'quiet';

    Blender::Message->set_verbose;

    my $dir = File::Temp->newdir;
    Blender::Logger->rotate( $dir );

    stdout_is { Blender::Message->notify( 'message' ) } "message\n", 'verbose';

    open my $fh, '<', Blender::Logger->logfile;
    my $logfile = ( <$fh> );
    close $fh;
    is( $logfile, "message\n", 'logfile' );

    stdout_is { Blender::Message->notify( "message\n" ) } "message\n",
              'message with return code';
          };

done_testing();

