package Blender::Command::Use;

use 5.012;
use warnings;

use parent qw/Blender::Command/;

use Blender::Catchme;

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

    my $used = eval { $target->use( $target_version ) };

	catchme 'Blender::Error' => sub {
        Blender::Message->alert( $@ );
        return;
	};

    if ( $used ) {
        Blender::App::Configuration->set_config( $used );
        Blender::App::Configuration->write_file;
    }

    return $used;
}

1;
