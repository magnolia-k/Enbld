package Blender::Command::Off;

use 5.012;
use warnings;

use parent qw/Blender::Command/;

require Blender::Home;
require Blender::App::Configuration;
require Blender::Error;
require Blender::Exception;
require Blender::Target;

sub do {
    my $self = shift;

    my $target_name = $self->validate_target_name( shift @{ $self->{argv} } );

    Blender::Home->initialize;
    Blender::App::Configuration->read_file;

    my $config = Blender::App::Configuration->search_config( $target_name );
    my $target = Blender::Target->new( $target_name, $config );

    my $offed;
    eval { $offed = $target->off };

    if ( $offed ) {
        Blender::App::Configuration->set_config( $offed );
    } 

    Blender::App::Configuration->write_file;

    if ( Blender::Error->caught ) {
        Blender::Message->notify( $@ );
        say "\nPlease check build logile:" . Blender::Logger->logfile;
        return;
    }

    if ( $@ ) {
        die $@;
    }

    return $offed;
}

1;
