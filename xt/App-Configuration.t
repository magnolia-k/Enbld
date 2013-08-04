#!/usr/bin/perl

use 5.012;
use warnings;

use File::Temp;
use File::Spec;
use Test::More;

require_ok( 'Blender::App::Configuration' );

require Blender::Feature;
require Blender::Home;
require Blender::Config;

subtest 'blendname' => sub {
    Blender::App::Configuration->set_blendname( 'blend' );
    my $blendname = Blender::App::Configuration->blendname;
    is( $blendname, 'blend', 'blend name' );

    Blender::App::Configuration->destroy;

    done_testing();
};

subtest 'no write configuration file' => sub {
    local $ENV{HOME} = File::Temp->newdir;

    Blender::Home->initialize;

    my $conf = File::Spec->catfile( Blender::Home->conf, 'blender.conf' );

    Blender::App::Configuration->write_file;

    ok( ! -e $conf, 'not write configuration file - not dirty' );

    Blender::Feature->initialize( deploy => File::Temp->newdir );

    my $config = Blender::Config->new( name => 'app' );
    Blender::App::Configuration->set_config( $config );

    Blender::App::Configuration->write_file;

    ok( ! -e $conf, 'not write configuration file - deploy mode' );

    done_testing();
};

subtest 'write and read config to configuration file' => sub {
    local $ENV{HOME} = File::Temp->newdir;

    Blender::Home->initialize;
    Blender::Feature->initialize;

    is( Blender::App::Configuration->read_file, undef, 'no read' );

    require Blender::Condition;
    my $condition = Blender::Condition->new( name => 'app', version => '1.0' );
    my $config = Blender::Config->new( name =>  'app' );
    $config->set_enabled( '1.0', $condition );

    Blender::App::Configuration->set_config( $config );

    Blender::App::Configuration->write_file;

    my $conf = File::Spec->catfile( Blender::Home->conf, 'blender.conf' );
    ok( -e $conf, 'write configuration file' );
    my $dummy = Blender::Config->new( name =>  'app', enabled  =>  '1.1' );
    Blender::App::Configuration->set_config( $dummy );

    Blender::App::Configuration->destroy;

    Blender::App::Configuration->read_file;
    my $read_config = Blender::App::Configuration->search_config( 'app' );

    is( $read_config->name, 'app', 'read configure - name' );
    is( $read_config->enabled, '1.0', 'read configure - enabled' );

    Blender::App::Configuration->destroy;

    done_testing();
};

subtest 'collection for config' => sub {
    subtest 'method success' => sub {
        require Blender::Condition;
        my $condition = Blender::Condition->new( name => 'app' );
        my $config = Blender::Config->new( name => 'app' );
        $config->set_enabled( '1.0', $condition );
        Blender::App::Configuration->set_config( $config );

        my $searched = Blender::App::Configuration->search_config( 'app' );
        
        is( $searched->name, 'app', 'got name' );
        is( $searched->enabled, '1.0', 'got enabled' );

        my $ref = Blender::App::Configuration->config;
        ok( exists $ref->{app}, 'config method' );

        Blender::App::Configuration->destroy;

        done_testing();
    };

    subtest 'no config' => sub {
        my $config = Blender::App::Configuration->search_config( 'dummy' );
        is( $config, undef, 'no config' );

        Blender::App::Configuration->destroy;

        done_testing();
    };

    done_testing();
};


require Blender::RcFile;

subtest 'write and read rcfile to configuration file' => sub {
    local $ENV{HOME} = File::Temp->newdir;

    require Blender::Home;
    Blender::Home->initialize;

    is( Blender::App::Configuration->read_file, undef, 'no read' );

    my $rcfile = Blender::RcFile->new(
            filepath    => '.blenderrc',
            contents    => 'content',
            command     => 'set',
            );

    $rcfile->do;

    Blender::App::Configuration->set_rcfile( $rcfile );
    Blender::App::Configuration->write_file;

    Blender::App::Configuration->destroy;

    Blender::App::Configuration->read_file;
    my $read = Blender::App::Configuration->search_rcfile( '.blenderrc' );

    is( $read->filename, '.blenderrc', 'read rcfile - filename' );

    Blender::App::Configuration->destroy;

    done_testing();
};

subtest 'collection for rcfile method' => sub {
    subtest 'method success' => sub {

        my $rcfile = Blender::RcFile->new(
                filepath    => '.blenderrc',
                contents    => 'content',
                command     => 'set',
                );

        $rcfile->do;

        Blender::App::Configuration->set_rcfile( $rcfile );

        my $searched = Blender::App::Configuration->search_rcfile(
                '.blenderrc'
                );
        
        is( $searched->filename, '.blenderrc', 'got filename' );

        my $ref = Blender::App::Configuration->rcfile;
        ok( exists $ref->{'.blenderrc'}, 'rcfile method' );

        Blender::App::Configuration->destroy;

        done_testing();
    };

    subtest 'no config' => sub {
        my $rcfile = Blender::App::Configuration->search_rcfile( 'dummy' );
        is( $rcfile, undef, 'no rcfile' );

        Blender::App::Configuration->destroy;

        done_testing();
    };

    done_testing();
};

done_testing();
