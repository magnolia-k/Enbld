package Blender::Command::Info;

use 5.012;
use warnings;

use parent qw/Blender::Command/;

require Blender::Home;
require Blender::App::Configuration;

sub do {
    my $self = shift;

    my $target_name = $self->validate_target_name( shift @{ $self->{argv} } );

    Blender::Home->initialize;
    Blender::App::Configuration->read_file;

    my $config = Blender::App::Configuration->search_config( $target_name );

    if ( ! $config ) {
        require Blender::Error;
        die Blender::Error->new( "Target '$target_name' is not installed yet.\n" );
    }

    print "$target_name\n";
    print "\n";
    print "Installed versions\n";
    for my $installed ( sort keys %{ $config->installed } ) {
        print '    ' . $installed . "\n";
    }

    return $self;
}

1;
