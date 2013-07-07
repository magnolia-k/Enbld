package Blender::Command::Off;

use 5.012;
use warnings;

use parent qw/Blender::Command/;

require Blender::Home;
require Blender::ConfigCollector;
require Blender::Error;
require Blender::Exception;
require Blender::Target;

sub do {
    my $self = shift;

    my $target_name = $self->validate_target_name( shift @{ $self->{argv} } );

    Blender::Home->initialize;
    Blender::ConfigCollector->read_configuration_file;

    my $config = Blender::ConfigCollector->search( $target_name );
    my $target = Blender::Target->new( $target_name, $config );

    my $offed;
    eval { $offed = $target->off };

    if ( $offed ) {
        Blender::ConfigCollector->set( $offed );
    } 

    Blender::ConfigCollector->write_configuration_file;

    if ( Blender::Error->caught or Blender::Exception->caught ) {
        Blender::Message->notify( $@ );
        return;
    }

    if ( $@ ) {
        die $@;
    }

    return $offed;
}

1;
