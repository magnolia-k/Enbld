package Blender::Command::List;

use 5.012;
use warnings;

use parent qw/Blender::Command/;

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
        
        print substr( $line, 0, 15 );

        if ( $config->enabled ) {
            print $config->enabled;
        } else {
            print 'Not enabled now...';
        }

        print "\n";
    }

    return $self;
}

1;
