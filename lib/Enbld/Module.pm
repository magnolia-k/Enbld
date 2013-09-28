package Enbld::Module;

use 5.012;
use warnings;

use Module::Load;
use Module::Load::Conditional qw/can_load/;

require Enbld::Message;
require Enbld::Error;

sub new {
    my $class = shift;

    my $self = {
        name            =>  undef,
        path            =>  undef,
        command         =>  undef,
        option          =>  undef,
        @_,
    };
    
    my $module = 'Enbld::Module::' . ucfirst( $self->{name} );
    if ( can_load( modules => { $module => undef } ) ) {
        load $module;

        bless $self, $module;
        $self->initialize;

        return $self;
    }

    die( Enbld::Error->new( "no module for target '$self->{name}'" ));
}

sub install {
    my ( $self, $modules ) = @_;

    require Enbld::Logger;
    my $logfile = Enbld::Logger->logfile;

    my $start_msg = "----> Start install modules for '$self->{name}'.";
    Enbld::Message->notify( $start_msg );

    foreach my $name ( sort keys %{ $modules } ) {

        my $module = $self->module( $name, $modules->{$name} );
        my $cmd = $self->install_command( $module );

        Enbld::Message->notify( "--> $cmd" );
        system( "$cmd >> $logfile 2>&1" );

        if ( $? >> 8 ) {
            my $err = "Build fail.Command:$cmd return code:" . ( $? >> 8 );
            die( Enbld::Error->new( $err ));
        }

    }

    my $end_msg = "----> Finish install modules for '$self->{name}'.";
    Enbld::Message->notify( $end_msg );

    return $self;
}

sub module {
    my ( $self, $name, $version ) = @_;
}

sub install_command {
    # virtual method
}

sub initialize {
    # virtual method
}

1;
