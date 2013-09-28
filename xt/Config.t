#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

use File::Spec;
use File::Temp;

require_ok( 'Enbld::Config' );

require Enbld::Condition;

subtest 'getter method' => sub {
    my $old = Enbld::Condition->new( name => 'app', version => '1.0' );
    my $new = Enbld::Condition->new( name => 'app', version => '1.1' );

    my $config = Enbld::Config->new( name => 'app' );
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
        my $config = Enbld::Config->new( name => 'app' );

        my $condition = Enbld::Condition->new;
        $config->set_enabled( '1.0', $condition );

        is( $config->condition( '1.0' )->version, 'latest', 'version' );

        done_testing();
    };

    subtest 'not set parameter' => sub {
        my $config = Enbld::Config->new( name => 'app' );

        my $condition = Enbld::Condition->new;
        $config->set_enabled( '1.0', $condition );

        is( $config->condition->version, 'latest', 'version' );

        done_testing();
    };

    subtest 'not exists' => sub {
        my $config = Enbld::Config->new( name => 'app' );

        my $condition = Enbld::Condition->new;
        $config->set_enabled( '1.0', $condition );

        is( $config->condition( '1.1' ), undef, 'not exists');

        done_testing();
    };

    done_testing();
};

subtest 'set enabled method' => sub {

    my $config = Enbld::Config->new( name =>  'app' );
    is( $config->enabled, undef, 'not enabled yet' );

    my $condition = Enbld::Condition->new( version => '1.0' );
    is( $config->set_enabled( '1.0', $condition ), '1.0', 'set enabled' );
    is( $config->enabled, '1.0', 'enabled' );
    is( $config->is_installed_version( '1.0' ), '1.0', 'installed' );

    done_testing();
};

subtest 'is installed version method' => sub {
    subtest 'no param' => sub {
        my $config = Enbld::Config->new( name => 'app' );
        is( $config->is_installed_version, undef, 'no param' );

        done_testing();
    };

    subtest 'not enabled yet' => sub {
        my $config = Enbld::Config->new( name => 'app' );
        is( $config->is_installed_version( '1.0' ), undef, 'not enabled yet' );

        done_testing();
    };

    subtest 'installed' => sub {
        my $condition = Enbld::Condition->new;
        my $config = Enbld::Config->new( name => 'app' );
        $config->set_enabled( '1.0', $condition );

        is( $config->is_installed_version( '1.0' ), '1.0', 'installed' );

        done_testing();
    };

    subtest 'not installed' => sub {
        my $condition = Enbld::Condition->new;
        my $config = Enbld::Config->new( name => 'app' );
        $config->set_enabled( '1.0', $condition );

        is( $config->is_installed_version( '1.1' ), undef, 'not installed' );

        done_testing();
    };

    done_testing();
};

subtest 'DSL' => sub {

    my $config = Enbld::Config->new( name => 'app' );

    my $condition = Enbld::Condition->new;
    $config->set_enabled( '1.0', $condition );
 
    my $DSL = $config->DSL;
    like( $DSL->[0], qr/target 'app' => define/, 'target name' );
    like( $DSL->[1], qr/version 'latest'/, 'version condition' );

    Enbld::Feature->initialize( current => 1 );

    my $current_DSL = $config->DSL;
    like( $current_DSL->[1], qr/version '1\.0'/, 'current version' );

    my $make_test_condition = Enbld::Condition->new( make_test => 1 );
    my $make_test_config = Enbld::Config->new( name => 'app' );
    $make_test_config->set_enabled( '1.0', $make_test_condition );
    my $make_test_DSL = $make_test_config->DSL;
    like( $make_test_DSL->[2], qr/make_test '1'/, 'make test' );

    my $modules_condition = Enbld::Condition->new( modules => {
                module_a => 0,
                module_b => 0,
            });

    my $modules_config = Enbld::Config->new( name => 'app' );
    $modules_config->set_enabled( '1.0', $modules_condition );
    my $modules_DSL = $modules_config->DSL;

    like( $modules_DSL->[3], qr/module_a/, 'module condition first' );
    like( $modules_DSL->[4], qr/module_b/, 'module condition second' );

    done_testing();
};

done_testing();
