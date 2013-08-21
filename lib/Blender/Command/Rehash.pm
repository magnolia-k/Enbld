package Blender::Command::Rehash;

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

    Blender::Home->initialize;
    Blender::App::Configuration->read_file;

    my $config = Blender::App::Configuration->search_config( $target_name );
    my $target = Blender::Target->new( $target_name, $config );

    eval { $target->rehash };

    if ( Blender::Error->caught ) {
        Blender::Message->alert( $@ );
        return;
    }

    if ( $@ ) {
        die $@;
    }

    return $target_name;
}

1;
