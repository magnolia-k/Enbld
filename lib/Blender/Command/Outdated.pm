package Blender::Command::Outdated;

use 5.012;
use warnings;

use parent qw/Blender::Command/;

require Blender::Home;
require Blender::App::Configuration;
require Blender::Target;
require Blender::Message;

sub do {
    my $self = shift;
  
    Blender::Home->initialize;
    Blender::App::Configuration->read_file;

    my %outdated;
    foreach my $name ( keys %{ Blender::App::Configuration->config } ) {
        my $config = Blender::App::Configuration->search_config( $name );
        my $target = Blender::Target->new( $name, $config );

        my $version = $target->is_outdated;

        if ( $version ) {
            $outdated{$name} = $version;
        }

    }

    if ( ! keys %outdated ) {
        print STDERR "no outdated targets.\n";
    }

    foreach my $name ( sort keys %outdated ) {
        my $config = Blender::App::Configuration->search_config( $name );

        print $name . ' ' x 4 . $config->enabled;
        print " < " . $outdated{$name} . "\n";
    }

    return $self;
}

1;
