#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

use File::Spec;
use File::Temp;

require_ok( 'Blender::Config' );
require_ok( 'Blender::ConfigCollector' );

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

subtest 'write and read configuration method' => sub {
    local $ENV{HOME} = File::Temp->newdir;
    require Blender::Home;
    Blender::Home->initialize;

    is( Blender::ConfigCollector->read_configuration_file, undef, 'no read' );

    require Blender::Condition;
    my $condition = Blender::Condition->new( name => 'app', version => '1.0' );
    my $config = Blender::Config->new( name =>  'app' );
    $config->set_enabled( '1.0', $condition );
    Blender::ConfigCollector->set( $config );
    Blender::ConfigCollector->write_configuration_file;

    my $dummy = Blender::Config->new( name =>  'app', enabled  =>  '1.1' );
    Blender::ConfigCollector->set( $dummy );

    Blender::ConfigCollector->destroy;

    Blender::ConfigCollector->read_configuration_file;
    my $read_config = Blender::ConfigCollector->search( 'app' );

    is( $read_config->name, 'app', 'read configure - name' );
    is( $read_config->enabled, '1.0', 'read configure - enabled' );

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
    subtest 'method exception' => sub {
        eval{ Blender::Config->new( name => 'app' )->set_enabled };
        like(
                $@,
                qr/ABORT:set_enabled method requires version string parameter/,
                'no param'
                );

        eval{ Blender::Config->new( name => 'app' )->set_enabled( '1.0' ) };
        like(
                $@,
                qr/ABORT:set_enabled method requires condition object/,
                'no condition param'
            );

        done_testing();
    };

    subtest 'method success' => sub {
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

subtest 'collector method' => sub {
    no Blender::ConfigCollector;
    require Blender::ConfigCollector;

    subtest 'no return' => sub {
        is( Blender::ConfigCollector->search, undef, 'no param' );

        done_testing();
    };

    subtest 'method success' => sub {
        require Blender::Condition;
        my $condition = Blender::Condition->new( name => 'app' );
        my $config = Blender::Config->new( name => 'app' );
        $config->set_enabled( '1.0', $condition );
        Blender::ConfigCollector->set( $config );

        my $searched = Blender::ConfigCollector->search( 'app' );
        is( $searched->name, 'app', 'got name' );
        is( $searched->enabled, '1.0', 'got enabled' );

        done_testing();
    };

    subtest 'no config' => sub {
        is( Blender::ConfigCollector->search( 'dummy' ), undef, 'no config' );

        done_testing();
    };

    subtest 'set method exception' => sub {
        eval { Blender::ConfigCollector->set };
        like( $@, qr/ABORT:set method requires config object/, 'no param' );

        done_testing();
    };

    done_testing();
};

done_testing();
