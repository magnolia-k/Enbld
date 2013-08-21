package Blender::Command::Use;

use 5.012;
use warnings;

use parent qw/Blender::Command/;

require Blender::Home;
require Blender::Error;
require Blender::App::Configuration;
require Blender::Target;

sub do {
    my $self = shift;

    my $target_name = $self->validate_target_name( shift @{ $self->{argv} } );
    my $target_version = shift @{ $self->{argv} };

    if ( ! $target_version ) {
        die( Blender::Error->new( "'use' command requires version param." ) );
    }

    Blender::Home->initialize;
    Blender::App::Configuration->read_file;

    my $config = Blender::App::Configuration->search_config( $target_name );
    my $target = Blender::Target->new( $target_name, $config );

    my $used;
    eval { $used = $target->use( $target_version ) };

    if ( $used ) {
        Blender::App::Configuration->set_config( $used );
        Blender::App::Configuration->write_file;
    }

    if ( Blender::Error->caught ) {
        Blender::Message->alert( $@ );
        return;
    }

    if ( $@ ) {
        die $@;
    }

    return $used;
}

1;
