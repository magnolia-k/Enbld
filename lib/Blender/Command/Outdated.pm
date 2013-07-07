package Blender::Command::Outdated;

use 5.012;
use warnings;

use parent qw/Blender::Command/;

require Blender::Home;
require Blender::ConfigCollector;
require Blender::Target;
require Blender::Message;

sub do {
    my $self = shift;
  
    Blender::Home->initialize;
    Blender::ConfigCollector->read_configuration_file;

    my %outdated;
    foreach my $name ( keys %{ Blender::ConfigCollector->collection } ) {
        my $config = Blender::ConfigCollector->search( $name );
        my $target = Blender::Target->new( $name, $config );

        my $version = $target->is_outdated;

        if ( $version ) {
            $outdated{$name} = $version;
        }

    }

    if ( ! keys %outdated ) {
        print STDERR "no outdated target.\n";
    }

    foreach my $name ( sort keys %outdated ) {
        my $config = Blender::ConfigCollector->search( $name );

        print $name . ' ' x 4 . $config->enabled;
        print " < " . $outdated{$name} . "\n";
    }

    return $self;
}

1;
