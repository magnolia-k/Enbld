package Blender::Command::Deploy;

use 5.012;
use warnings;

use parent qw/Blender::Command/;

require Blender::Feature;
require Blender::Home;
require Blender::Logger;
require Blender::App::Configuration;
require Blender::Target;
require Blender::Deployed;

sub do {
    my $self = shift;

    my $deploy_path = shift @{ $self->{argv} };

    unless ( $deploy_path ) {
        die( "ERROR:'deploy' command requires directory path argument.\n" );
    }

    Blender::Feature->set_deploy_mode( $deploy_path );
    Blender::Home->initialize;
    Blender::Home->create_build_directory;
    Blender::Logger->rotate( Blender::Home->log );

    Blender::App::Configuration->read_file;

    foreach my $name ( keys %{ Blender::App::Configuration->config } ) {
        my $config = Blender::App::Configuration->search_config( $name );

        next unless $config->enabled;

        my $target = Blender::Target->new( $name, $config );
        my $condition = {
            $name   =>  $config->condition( $config->enabled ),
        };

        my $installed;
        eval { $installed = $target->deploy_declared( $condition ) };

        # Catch exception.
        if ( Blender::Error->caught ) {
            Blender::Message->alert( $@ );
            say "Please check build logile:" . Blender::Logger->logfile;

            return;
        }

        die $@ if ( $@ );

        # installed
        if ( $installed ) {
            Blender::Deployed->add( $installed );
        }
    }        
}

1;
