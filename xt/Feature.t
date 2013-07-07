#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

use File::Temp;

require_ok( 'Blender::Feature' );

subtest 'no deploy' => sub {

    Blender::Feature->initialize(
            force       => 1,
            make_test   => 1,
            current     => 1,
            );

    is( Blender::Feature->is_force_install, 1, 'force' );
    is( Blender::Feature->is_make_test_all, 1, 'make test' );
    is( Blender::Feature->is_current_mode,  1, 'current' );

    Blender::Feature->reset;

    done_testing();
};

subtest 'set deploy mode' => sub {

    Blender::Feature->initialize;

    my $dir = File::Temp->newdir;
    Blender::Feature->set_deploy_mode( $dir );

    ok( Blender::Feature->is_deploy_mode, 'is deploy mode' );
    is( Blender::Feature->deploy_path, $dir, 'deploy path' );

    Blender::Feature->reset;

    done_testing();
};

subtest 'set invalid deploy path' => sub {

    Blender::Feature->initialize;

    my $dir = 'invalid/';
    eval { Blender::Feature->set_deploy_mode( $dir ) };
    like( $@, qr/ERROR:'$dir' is nonexistent/, 'set invalid deploy path' );

    Blender::Feature->reset;

    done_testing();

};

subtest 'set deploy path at initialization' => sub {

    my $dir = File::Temp->newdir;
    Blender::Feature->initialize( deploy => $dir );

    ok( Blender::Feature->is_deploy_mode, 'is deploy mode' );
    is( Blender::Feature->deploy_path, $dir, 'deploy path' );

    Blender::Feature->reset;

    done_testing();

};

SKIP: {
          skip "skip ... in root user", 1 unless ( $> );
          
          subtest 'set no write permission deploy path' => sub {

              Blender::Feature->initialize;

              my $dir = File::Temp->newdir;
              chmod 0444, $dir;

              eval{ Blender::Feature->set_deploy_mode( $dir ) };
              like( $@, qr/ERROR:no permission to write directory/,
                      'set no write permission' );

              chmod 0755, $dir;
              Blender::Feature->reset;

              done_testing();
          
          };
};
done_testing();
