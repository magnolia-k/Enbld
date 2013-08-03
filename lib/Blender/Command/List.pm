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
        print $name;
        print '    ' . $config->enabled if $config->enabled;
        print "\n";
    }

    return $self;
}

1;
