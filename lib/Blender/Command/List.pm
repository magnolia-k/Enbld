package Blender::Command::List;

use 5.012;
use warnings;

use parent qw/Blender::Command/;

use Encode;

require Blender::Home;
require Blender::App::Configuration;
require Blender::Message;

sub do {
    my $self = shift;

    Blender::Home->initialize;
    Blender::App::Configuration->read_file;

    my $collection = Blender::App::Configuration->config;

    if ( ! keys %{ $collection } ) {
        say "Nothing is installed yet.";
    }

    foreach my $name ( sort keys %{ $collection } ) {
        my $config = Blender::App::Configuration->search_config( $name );
        
        my $line = $name . ' ' x 15;
        
        print substr( $name . ' ' x 15 , 0, 15 );

        my $version;
        if ( $config->enabled ) {
            $version = $config->enabled;
        } else {
            $version = 'Not enabled now...';
        }

        print substr( $version . ' ' x 20, 0, 20 );

        if ( $config->condition->annotation ) {
            print encode( 'UTF-8', $config->condition->annotation );
        }

        print "\n";
    }

    return $self;
}

1;
