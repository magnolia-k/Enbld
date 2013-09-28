package Enbld::Command::List;

use 5.012;
use warnings;

use parent qw/Enbld::Command/;

use Encode;

require Enbld::Home;
require Enbld::App::Configuration;

sub do {
    my $self = shift;

    Enbld::Home->initialize;
    Enbld::App::Configuration->read_file;

    my $collection = Enbld::App::Configuration->config;

    if ( ! keys %{ $collection } ) {
        say "Nothing is installed yet.";
    }

    foreach my $name ( sort keys %{ $collection } ) {
        my $config = Enbld::App::Configuration->search_config( $name );
        
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
