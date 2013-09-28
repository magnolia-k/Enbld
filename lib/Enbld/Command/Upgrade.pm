package Enbld::Command::Upgrade;

use 5.012;
use warnings;

use parent qw/Enbld::Command/;

use Enbld::Catchme;

require Enbld::App::Configuration;
require Enbld::Error;
require Enbld::Exception;
require Enbld::Message;
require Enbld::Target;
require Enbld::Feature;

sub do {
    my $self = shift;

    my $target_name = $self->validate_target_name( shift @{ $self->{argv} } );
    
    $self->setup;
    
    my $config = Enbld::App::Configuration->search_config( $target_name );
    my $target = Enbld::Target->new( $target_name, $config );

    my $installed = eval{
		$target->upgrade
	};

	catchme 'Enbld::Error' => sub {
        Enbld::Message->alert( $@ );
        say "\nPlease check build logile:" . Enbld::Logger->logfile;
        return;
	};

    if ( $installed ) {
        Enbld::App::Configuration->set_config( $installed );
    }
    
    $self->teardown;

    return $installed;
}

1;
