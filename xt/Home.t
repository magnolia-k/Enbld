#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

use FindBin;
use File::Temp;
use Time::Piece;
use Time::Seconds;
use File::Path qw/make_path/;

require_ok( 'Blender::Home' );
require Blender::Feature;

eval { Blender::Home->home };
like( $@, qr/ABORT:Not initialized blender home's path yet./,
          'not initialized' );

SKIP: {
          skip "skip ... in root user", 2 unless ( $> );

          subtest 'create blender home' => sub {

              my $dir = File::Temp->newdir; 
              local $ENV{PERL_BLENDER_HOME} = File::Spec->catdir( $dir, 'blended' );

              chmod 0444, $dir;

              eval { Blender::Home->initialize };
              like( $@, qr/ERROR:Can't create blender's home/,
                      'no permission to higher level directory' );
              
              chmod 0755, $dir;
              chdir $FindBin::Bin;
              
              done_testing();
          };

          subtest 'check write permission blender home' => sub {

              my $dir = File::Temp->newdir;

              local $ENV{PERL_BLENDER_HOME} = $dir;
              chmod 0444, $dir;

              eval { Blender::Home->initialize };
              like( $@, qr/ERROR:No permission to write directory/,
                      "no permission to blender's home directory" );

              chmod 0755, $dir;
              chdir $FindBin::Bin;

              done_testing();
          };
      };

local $ENV{PERL_BLENDER_HOME} = File::Temp->newdir;

ok( Blender::Home->initialize, 'initialize method' );
is( Blender::Home->home, $ENV{PERL_BLENDER_HOME}, 'home dir' );
ok( -d Blender::Home->dists,        'dists dir' );
ok( -d Blender::Home->depository,   'depository dir' );
ok( -d Blender::Home->conf,         'conf dir' );
ok( -d Blender::Home->etc,          'etc dir' );
ok( -d Blender::Home->log,          'log dir' );

my $dir = Blender::Home->create_build_directory;
ok( -d $dir, 'build dir' );

eval { Blender::Home->invalid };
like( $@, qr/Can't execute Blender::Home's method/, 'invalid method' );


subtest 'remove build directory' => sub {

	local $ENV{PERL_BLENDER_HOME} = File::Temp->newdir;

	Blender::Home->initialize;
	
	my $oldtime = localtime;
	$oldtime -= ONE_YEAR;

	my $newtime = localtime;
	$newtime -= ONE_DAY;

	my $old_dir = File::Spec->catdir( Blender::Home->build, $oldtime->epoch );
	my $new_dir = File::Spec->catdir( Blender::Home->build, $newtime->epoch );
	make_path( $old_dir );
	make_path( $new_dir );

	ok( -d $old_dir, 'old build directory is in existence' );
	ok( -d $new_dir, 'new build directory is in existence' );

	Blender::Home->initialize;

	ok( ! -d $old_dir, 'old build directory disappears' );
	ok( -d $new_dir,   'new build directory exists' );

	done_testing();
};

subtest 'set deploy path' => sub {

	local $ENV{PERL_BLENDER_HOME} = File::Temp->newdir;

	Blender::Home->initialize;
    is( Blender::Home->library, Blender::Home->home, 'library path is home' );

	local $ENV{PERL_BLENDER_HOME} = File::Temp->newdir;
    my $deploy_path = File::Temp->newdir;

    require Blender::Feature;
    Blender::Feature->initialize( deploy => $deploy_path );

    Blender::Home->initialize;
    is( Blender::Home->deploy_path, $deploy_path, 'set deploy path' );
    is( Blender::Home->library, $deploy_path, 'library path is deploy path' );

    done_testing();
};

done_testing();

