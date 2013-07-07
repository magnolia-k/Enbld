package Blender::Command::Deploy;

use 5.012;
use warnings;

use parent qw/Blender::Command/;

require Blender::Feature;
require Blender::Home;
require Blender::Logger;
require Blender::ConfigCollector;
require Blender::Target;

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

    Blender::ConfigCollector->read_configuration_file;

    foreach my $name ( keys %{ Blender::ConfigCollector->collection } ) {
        my $config = Blender::ConfigCollector->search( $name );

        next unless $config->enabled;

        my $target = Blender::Target->new( $name, $config );
        my $condition = $config->condition( $config->enabled );

        my $installed;
        eval { $installed = $target->install_declared( $condition ) };
    }        
}

1;
