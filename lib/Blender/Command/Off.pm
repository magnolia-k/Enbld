package Blender::Command::Off;

use 5.012;
use warnings;

use parent qw/Blender::Command/;

use Blender::Catchme;

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

    my $offed = eval { $target->off };

	catchme 'Blender::Error' => sub {
        Blender::Message->notify( $@ );
        return;
	};

    if ( $offed ) {
        Blender::App::Configuration->set_config( $offed );
    } 

    Blender::App::Configuration->write_file;

    return $offed;
}

1;
