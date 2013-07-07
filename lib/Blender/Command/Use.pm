package Blender::Command::Use;

use 5.012;
use warnings;

use parent qw/Blender::Command/;

require Blender::Home;
require Blender::Error;
require Blender::ConfigCollector;
require Blender::Target;

sub do {
    my $self = shift;

    my $target_name = $self->validate_target_name( shift @{ $self->{argv} } );
    my $target_version = shift @{ $self->{argv} };

    if ( ! $target_version ) {
        die( Blender::Error->new( "'use' command requires version param." ) );
    }

    Blender::Home->initialize;
    Blender::ConfigCollector->read_configuration_file;

    my $config = Blender::ConfigCollector->search( $target_name );
    my $target = Blender::Target->new( $target_name, $config );

    my $used;
    eval { $used = $target->use( $target_version ) };

    if ( $used ) {
        Blender::ConfigCollector->set( $used );
    }


    Blender::ConfigCollector->write_configuration_file;

    if ( Blender::Error->caught or Blender::Exception->caught ) {
        Blender::Message->notify( $@ );
        return;
    }

    if ( $@ ) {
        die $@;
    }

    return $used;
}

1;
