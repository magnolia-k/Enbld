#!/usr/bin/perl

use 5.012;
use warnings;

use File::Spec;
use File::Copy;
use File::Temp;
use FindBin;

use lib "$FindBin::Bin/./testlib/";

use Test::More;

require_ok( 'Blender::Target' );

subtest 'constructor' => sub {
    eval { Blender::Target->new };
    like( $@, qr/ABORT:'Blender::Target' require name/, 'no name' );

    eval { Blender::Target->new( '---app---' ) };
    like( $@, qr/ERROR:invalid target name '---app---'/, 'invalid name' );

    eval { Blender::Target->new( 'noname' ) };
    like( $@, qr/ERROR:no definition for target 'noname'/, 'no definition' );

    done_testing();
};

set_http_hook(); 

subtest "install" => sub {

    subtest 'not installed' => sub {
        setup();

        my $target = Blender::Target->new( 'testapp' );
        is( $target->is_installed, undef, 'not installed' );

        my $config = $target->install;
        is( $config->enabled, '1.1', 'install method' );

        teardown();
        done_testing();
    };

    subtest 'installed' => sub {
        setup();

        my $config = Blender::Target->new( 'testapp' )->install;
        eval { Blender::Target->new( 'testapp', $config )->install };
        like ( $@, qr/ERROR:'testapp' is already installed/, 'installed' );

        teardown();
        done_testing();
    };

    subtest 'force install' => sub {
        setup();

        my $config = Blender::Target->new( 'testapp' )->install;
        is( $config->enabled, '1.1', 'install first' );

        teardown();
        setup( force => 1 );

        my $target = Blender::Target->new( 'testapp', $config );
        my $installed = $target->install;
        is( $installed->enabled, '1.1', 'install twice' );

        teardown();
        done_testing();
    };

    subtest 'install with make test' => sub {
        setup( make_test => 1 );

        Blender::Target->new( 'testapp' )->install;

        my $path = File::Spec->catfile(
                Blender::Home->build,
                'TestApp-1.1',
                'tested'
                );
        ok( -e $path, 'make test' ) or diag( $@ );

        teardown();
        done_testing();
    };

    subtest 'install without make test' => sub {
        setup( make_test => undef );

        Blender::Target->new( 'testapp' )->install;

        my $path = File::Spec->catfile(
                Blender::Home->build,
                'TestApp-1.1',
                'tested'
                );
        ok( ! -e $path, 'not make test' );

        teardown();

        done_testing();
    };

    subtest 'install deploy' => sub {
        setup();
        
        my $config = Blender::Target->new( 'testapp' )->install;

        my $deploy_path = File::Temp->newdir;
        teardown();
        setup( deploy => $deploy_path );

        Blender::Target->new( 'testapp', $config )->install;

        my $app = File::Spec->catdir( $deploy_path, 'bin', 'blendertestapp' );
        ok( -e $app, 'deploy' );

        teardown();
        done_testing();
    };

    done_testing();
};

subtest 'install dependant' => sub {

    subtest 'install dependency' => sub {
        setup();

        my $dependant = Blender::Target->new( 'testdependant' )->install;
        is( $dependant->name, 'testdependant', 'dependant name' );
        is( $dependant->enabled, '1.1', 'dependant enabled' );

        require Blender::ConfigCollector;
        my $config = Blender::ConfigCollector->search( 'testapp' );
        is( $config->name, 'testapp', 'dependency name' );
        is( $config->enabled, '1.1', 'dependency enabled' );

        teardown();
        done_testing();
    };

    subtest 'not install dependency' => sub {
        setup();
    
        my $dependency = Blender::Target->new( 'testapp' )->install;
        Blender::ConfigCollector->set( $dependency );

        my $installed = Blender::ConfigCollector->search( 'testapp' );
        is( $installed->enabled, '1.1', 'installed dependency' );

        my $config = Blender::Target->new( 'testdependant' )->install;
        is( $config->enabled, '1.1', 'installed target' );

        teardown();
        done_testing();
    };

    subtest 'install by specific condition' => sub {
        setup();

        my $condition = Blender::Condition->new(
                name => 'testapp',
                version => '1.0'
                );
        Blender::ConditionCollector->add( $condition );

        my $dependant = Blender::Target->new( 'testdependant' )->install;
        is( $dependant->enabled, '1.1', 'enabled' );

        my $config = Blender::ConfigCollector->search( 'testapp' );
        is( $config->name, 'testapp', 'target name' );
        is( $config->enabled, '1.0', 'target enabled' );

        teardown();
        done_testing();
    };

    done_testing();
};

subtest 'install declared' => sub {

    subtest 'installed declared condition' => sub {
        setup();

        my $old = Blender::Condition->new(
                name => 'testapp',
                version => '1.0'
                );

        my $testapp =
            Blender::Target->new( 'testapp' )->install_declared( $old );

        is( $testapp->name, 'testapp', 'target name' );
        is( $testapp->enabled, '1.0', 'target version' );

        is( Blender::Target->new(
                    'testapp', $testapp )->install_declared( $old ),
                undef, 'not installed' );

        my $new = Blender::Condition->new(
                name => 'testapp',
                version => '1.1'
                );

        my $config = Blender::Target->new( 'testapp',
                    $testapp )->install_declared( $new );
        is( $config->enabled, '1.1', 'installed' );

        teardown();
        done_testing();
    };

    subtest 'force install' => sub {
        setup();

        my $condition = Blender::Condition->new(
                name => 'testapp',
                version => '1.0'
                );

        my $target_first = Blender::Target->new( 'testapp' );
        my $config_first = $target_first->install_declared( $condition );
        is( $config_first->enabled, '1.0', 'install first' );

        teardown();
        setup( force => 1 );

        my $target_twice = Blender::Target->new( 'testapp' );
        my $config_twice = $target_twice->install_declared( $condition );
        is( $config_twice->enabled, '1.0', 'install twice by force' );

        teardown();
        done_testing();

    };

    subtest 'install deploy' => sub {
        setup();
        
        my $con = Blender::Condition->new(
                name => 'testapp',
                version => '1.0'
                );

        my $config =
            Blender::Target->new( 'testapp' )->install_declared( $con );

        teardown();
        my $deploy_path = File::Temp->newdir;
        setup( deploy => $deploy_path );

        Blender::Target->new( 'testapp', $config )->install_declared( $con );

        my $app = File::Spec->catdir( $deploy_path, 'bin', 'blendertestapp' );
        ok( -e $app, 'deploy' );

        teardown();
        done_testing();
    };

    done_testing();
};

subtest 'upgrade' => sub {

    subtest 'not installed' => sub {
        setup();

        eval{ Blender::Target->new( 'testapp' )->upgrade };
        like( $@, qr/ERROR:'testapp' is not installed yet/, 'not installed' );

        teardown();
        done_testing();
    };

    subtest 'not upgrade' => sub {
        setup();

        my $old = Blender::Condition->new(
                name => 'testapp',
                version => '1.1'
                );
        my $config =
            Blender::Target->new( 'testapp' )->install_declared( $old );

        my $new = Blender::Condition->new(
                name => 'testapp',
                version => 'latest'
                );
        $config->set_enabled( '1.1', $new );

        eval{ Blender::Target->new( 'testapp', $config )->upgrade };
        like( $@, qr/ERROR:'testapp' is up to date/, 'not upgrade' );

        teardown();
        done_testing();
    };

    subtest 'upgrade install' => sub {
        setup();

        my $target = Blender::Target->new( 'testapp' );
        my $old = Blender::Condition->new(
                name => 'testapp',
                version => '1.0'
                );
        my $config =
            Blender::Target->new( 'testapp' )->install_declared( $old );

        my $new = Blender::Condition->new(
                name => 'testapp',
                version => 'latest'
                );
        $config->set_enabled( '1.0', $new );

        my $upgraded = Blender::Target->new( 'testapp', $config )->upgrade;
        is( $upgraded->enabled, '1.1', 'upgraded' );

        teardown();
        done_testing();
    };

    done_testing();
};

subtest 'is outdated' => sub {
    subtest 'not installed' => sub {
        setup();

        my $target = Blender::Target->new( 'testapp' );
        is( $target->is_outdated, undef, 'not installed' );

        teardown();
        done_testing();
    };

    subtest 'outdated' => sub {
        setup();

        my $old = Blender::Condition->new(
                name => 'testapp',
                version => '1.0'
                );
        my $config =
            Blender::Target->new( 'testapp' )->install_declared( $old );

        my $new = Blender::Condition->new(
                name => 'testapp',
                version => 'latest'
                );
        $config->set_enabled( '1.0', $new );
        my $outdated = Blender::Target->new( 'testapp', $config );

        is( Blender::Target->new( 'testapp', $config )->is_outdated,
                '1.1', 'outdated' );

        teardown();
        done_testing();
    };

    subtest 'not outdated' => sub {
        setup();

        my $old = Blender::Condition->new(
                name => 'testapp',
                version => '1.1'
                );
        my $config =
            Blender::Target->new( 'testapp' )->install_declared( $old );

        my $new = Blender::Condition->new(
                name => 'testapp',
                version => 'latest'
                );
        $config->set_enabled( '1.1', $new );
        my $uptodate = Blender::Target->new( 'testapp', $config );

        is( Blender::Target->new( 'testapp', $config )->is_outdated,
                undef, 'up to date' );

        teardown();
        done_testing();
    };

    done_testing();
};

subtest 'use method' => sub {

    subtest 'version form exception' => sub {
        setup();

        my $condition = Blender::Condition->new( name => 'testapp' );
        my $config = Blender::Config->new( name => 'testapp' );
        $config->set_enabled( '1.0', $condition );
 
        eval{ Blender::Target->new( 'testapp', $config )->use( '10' ) };

        like( $@, qr/ERROR:'10' is not valid version form/, 'form exception' );

        teardown();
        done_testing();
    };

    subtest 'current version exception' => sub {
        setup();

        my $condition = Blender::Condition->new( name => 'testapp' );
        my $config = Blender::Config->new( name => 'testapp' );
        $config->set_enabled( '1.0', $condition );

        eval{ Blender::Target->new( 'testapp', $config )->use( '1.0' ) };

        like( $@, qr/ERROR:'1.0' is current enabled version/, 'current' );

        teardown();
        done_testing();
    };

    subtest 'not installed yet' => sub {
        setup();

        my $condition = Blender::Condition->new( name => 'testapp' );
        my $config = Blender::Config->new( name => 'testapp' );
        $config->set_enabled( '1.0', $condition );

        eval{ Blender::Target->new( 'testapp', $config )->use( '1.1' ) };

        like( $@, qr/ERROR:'1.1' isn't installed yet/, 'not installed' );

        teardown();
        done_testing();
    };

    subtest 'use already installed' => sub {
        setup();

        my $old_condition =
            Blender::Condition->new( name => 'testapp',version => '1.0' );
        my $new_condition =
            Blender::Condition->new( name => 'testapp',version => 'latest' );
        my $old_config = Blender::Config->new( name => 'testapp' );
        my $old_target = Blender::Target->new( 'testapp' );

        my $new_config = $old_target->install_declared( $old_condition );
        my $new_target = Blender::Target->new( 'testapp', $new_config );
        my $installed_config = $new_target->install_declared( $new_condition );

        my $target = Blender::Target->new( 'testapp', $installed_config );

        my $config = $target->use( '1.0' );
        is( $config->enabled, '1.0', 'use already installed version' );

        is( $config->condition->version, '1.0', 'after installed condition' );

        teardown();
        done_testing();
    };

    done_testing();
};

subtest 'off method' => sub {
    setup();

    my $config = Blender::Target->new( 'testapp' )->install;
    is( $config->enabled, '1.1', 'target install' );

    my $offed = Blender::Target->new( 'testapp', $config )->off;
    is( $offed->enabled, undef, 'target off' );

    eval { Blender::Target->new( 'testapp', $offed )->off };
    like( $@, qr/ERROR:'testapp' is not installed yet/, "can't off" );

    teardown();
    done_testing();
};

done_testing();

sub setup {

    local $ENV{PERL_BLENDER_HOME} = File::Temp->newdir;

    my $param = {
        force       =>  undef,
        make_test   =>  undef,
        deploy      =>  undef,
        @_,
    };

    require Blender::Feature;
    Blender::Feature->initialize( %{ $param } );

    require Blender::Home;
    Blender::Home->initialize;
    Blender::Home->create_build_directory;

    require Blender::Logger;
    Blender::Logger->rotate( Blender::Home->log );

    require Blender::ConfigCollector;
    require Blender::ConditionCollector;
}

sub teardown {
    Blender::ConfigCollector->destroy;
    Blender::ConditionCollector->destroy;

    Blender::Feature->reset;

    chdir;
};

sub set_http_hook {

    my $html = do { local $/; <DATA> };

    require Blender::HTTP;
    Blender::HTTP->register_get_hook( sub{ return $html } );
    Blender::HTTP->register_download_hook( \&download_hook );
}

sub download_hook {
    my ( $self, $path ) = @_;

    my ( undef, undef, $file ) = File::Spec->splitpath( $path );

    my $downloadfile = File::Spec->catfile( $FindBin::Bin, $file );
    copy( $downloadfile, $path );

    return $path;
}

__DATA__
<html>
<body>
<a href="TestApp-1.0.tar.gz">TestApp-1.0.tar.gz</a>
<a href="TestApp-1.1.tar.gz">TestApp-1.1.tar.gz</a>
</body>
</html>

