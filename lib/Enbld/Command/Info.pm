package Enbld::Command::Info;

use 5.012;
use warnings;

use parent qw/Enbld::Command/;

require Enbld::Home;
require Enbld::App::Configuration;

sub do {
    my $self = shift;

    my $target_name = $self->validate_target_name( shift @{ $self->{argv} } );

    Enbld::Home->initialize;
    Enbld::App::Configuration->read_file;

    my $config = Enbld::App::Configuration->search_config( $target_name );

    if ( ! $config ) {
        require Enbld::Error;
        die Enbld::Error->new( "Target '$target_name' is not installed yet.\n" );
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
