package Blender::Command::Install;

use 5.012;
use warnings;

use parent qw/Blender::Command/;

require Blender::App::Configuration;
require Blender::Error;
require Blender::Exception;
require Blender::Message;
require Blender::Target;
require Blender::Logger;

sub do {
    my $self = shift;

    my $target_name = $self->validate_target_name( shift @{ $self->{argv} } );

    $self->setup;

    my $config = Blender::App::Configuration->search_config( $target_name );
    my $target = Blender::Target->new( $target_name, $config );

    my $installed;
    eval {
        $installed = $target->install;
    };

    if ( $installed ) {
        Blender::App::Configuration->set_config( $installed );
    }

    $self->teardown;

    if ( Blender::Error->caught or Blender::Exception->caught ) {
        Blender::Message->notify( $@ );
        say "\nPlease check build logile:" . Blender::Logger->logfile;
        return;
    }

    if ( $@ ) {
        die $@;
    }

    return $installed;
}

1;
