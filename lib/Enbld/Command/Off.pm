package Enbld::Command::Off;

use 5.012;
use warnings;

use parent qw/Enbld::Command/;

use Enbld::Catchme;

require Enbld::Home;
require Enbld::App::Configuration;
require Enbld::Error;
require Enbld::Exception;
require Enbld::Target;

sub do {
    my $self = shift;

    my $target_name = $self->validate_target_name( shift @{ $self->{argv} } );

    Enbld::Home->initialize;
    Enbld::App::Configuration->read_file;

    my $config = Enbld::App::Configuration->search_config( $target_name );
    my $target = Enbld::Target->new( $target_name, $config );

    my $offed = eval { $target->off };

	catchme 'Enbld::Error' => sub {
        Enbld::Message->notify( $@ );
        return;
	};

    if ( $offed ) {
        Enbld::App::Configuration->set_config( $offed );
    } 

    Enbld::App::Configuration->write_file;

    return $offed;
}

1;
