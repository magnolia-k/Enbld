#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

use File::Spec;
use File::Temp;

require_ok( 'Blender::Config' );

subtest 'constructor method' => sub {
    eval { Blender::Config->new };
    like( $@, qr/ABORT:'Blender::Config' requires name/, 'construct fail' );

    done_testing();
};

subtest 'getter method' => sub {
    require Blender::Condition;
    my $old = Blender::Condition->new( name => 'app', version => '1.0' );
    my $new = Blender::Condition->new( name => 'app', version => '1.1' );

    my $config = Blender::Config->new( name => 'app' );
    $config->set_enabled( '1.0', $old );
    $config->set_enabled( '1.1', $new );

    is( $config->name, 'app', 'name' );
    is( $config->enabled, '1.1', 'enabled' );

    is( $config->condition->version, '1.1', 'version condition no param' );
    is( $config->condition( '1.0' )->version, '1.0', 'sepecific version' );

    done_testing();
};

subtest 'condition method' => sub {
    subtest 'set parameter' => sub {
        my $config = Blender::Config->new( name => 'app' );
        require Blender::Condition;
        my $condition = Blender::Condition->new( name => 'app' );
        $config->set_enabled( '1.0', $condition );

        is( $config->condition( '1.0' )->name, 'app', 'condition name' );
        is( $config->condition( '1.0' )->version,
                'latest', 'condition version' );

        done_testing();
    };

    subtest 'not set parameter' => sub {
        my $config = Blender::Config->new( name => 'app' );
        require Blender::Condition;
        my $condition = Blender::Condition->new( name => 'app' );
        $config->set_enabled( '1.0', $condition );

        is( $config->condition->name, 'app', 'condition name' );
        is( $config->condition->version, 'latest', 'condition version' );

        done_testing();
    };

    subtest 'not exists exception' => sub {
        my $config = Blender::Config->new( name => 'app' );
        require Blender::Condition;
        my $condition = Blender::Condition->new( name => 'app' );
        $config->set_enabled( '1.0', $condition );

        is( $config->condition( '1.1' ), undef, 'not exists');

        done_testing();
    };

    done_testing();
};

subtest 'set enabled method' => sub {
    my $config = Blender::Config->new( name =>  'app' );
    is( $config->enabled, undef, 'null enabled' );

    require Blender::Condition;
    my $condition =
        Blender::Condition->new( name => 'app', version => '1.0' );
    is( $config->set_enabled( '1.0', $condition ), '1.0', 'set enabled' );
    is( $config->enabled, '1.0', 'enabled' );
    is( $config->is_installed_version( '1.0' ), '1.0', 'installed' );

    done_testing();
};

subtest 'is installed version method' => sub {
    subtest 'no param' => sub {
        my $config = Blender::Config->new( name => 'app' );
        is( $config->is_installed_version, undef, 'no param' );

        done_testing();
    };

    subtest 'not enabled yet' => sub {
        my $config = Blender::Config->new( name => 'app' );
        is( $config->is_installed_version( '1.0' ), undef, 'not enabled yet' );

        done_testing();
    };

    subtest 'installed' => sub {
        require Blender::Condition;
        my $condition = Blender::Condition->new( name => 'app' );
        my $config = Blender::Config->new( name => 'app' );
        $config->set_enabled( '1.0', $condition );

        is( $config->is_installed_version( '1.0' ), '1.0', 'installed' );

        done_testing();
    };

    subtest 'not installed' => sub {
        require Blender::Condition;
        my $condition = Blender::Condition->new( name => 'app' );
        my $config = Blender::Config->new( name => 'app' );
        $config->set_enabled( '1.0', $condition );

        is( $config->is_installed_version( '1.1' ), undef, 'not installed' );

        done_testing();
    };

    done_testing();
};

subtest 'DSL' => sub {

    my $config = Blender::Config->new( name => 'app' );

    require Blender::Condition;
    my $condition = Blender::Condition->new( name => 'app' );
    $config->set_enabled( '1.0', $condition );
 
    my $DSL = $config->DSL;
    like( $DSL->[0], qr/target 'app' => define/, 'target name' );
    like( $DSL->[1], qr/version 'latest'/, 'version condition' );

    Blender::Feature->initialize( current => 1 );

    my $current_DSL = $config->DSL;
    like( $current_DSL->[1], qr/version '1\.0'/, 'current version' );

    my $make_test_condition = Blender::Condition->new(
            name => 'app',
            make_test => 1,
            );
    my $make_test_config = Blender::Config->new( name => 'app' );
    $make_test_config->set_enabled( '1.0', $make_test_condition );
    my $make_test_DSL = $make_test_config->DSL;
    like( $make_test_DSL->[2], qr/make_test '1'/, 'make test' );

    my $modules_condition = Blender::Condition->new(
            name => 'app',
            modules => {
                module_a => 0,
                module_b => 0,
            },
            );

    my $modules_config = Blender::Config->new( name => 'app' );
    $modules_config->set_enabled( '1.0', $modules_condition );
    my $modules_DSL = $modules_config->DSL;

    like( $modules_DSL->[3], qr/module_a/, 'module condition first' );
    like( $modules_DSL->[4], qr/module_b/, 'module condition second' );

    done_testing();
};

done_testing();
