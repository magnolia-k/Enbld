package Blender::Command::List;

use 5.012;
use warnings;

use parent qw/Blender::Command/;

require Blender::Home;
require Blender::ConfigCollector;
require Blender::Message;

sub do {
    my $self = shift;

    Blender::Home->initialize;
    Blender::ConfigCollector->read_configuration_file;

    my $collection = Blender::ConfigCollector->collection;

    if ( ! keys %{ $collection } ) {
        say "Nothing is installed yet.";
    }

    foreach my $name ( sort keys %{ $collection } ) {
        my $config = Blender::ConfigCollector->search( $name );
        print $name;
        print '    ' . $config->enabled if $config->enabled;
        print "\n";
    }

    return $self;
}

1;
