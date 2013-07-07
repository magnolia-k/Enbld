package Blender::Module;

use 5.012;
use warnings;

require Blender::Message;
require Blender::Error;

sub new {
    my $class = shift;

    my $self = {
        name            =>  undef,
        install_path    =>  undef,
        command         =>  undef,
        option          =>  undef,
        @_,
    };
    
    my $module = 'Blender::Module::' . ucfirst( $self->{name} );
    require Blender::Require;
    eval { Blender::Require->try_require( $module ) };

    if ( $@ ) {
        die( Blender::Error->new( "no module for target '$self->{name}'" ));
    }

    bless $self, $module;

    $self->initialize;

    return $self;
}

sub install {
    my ( $self, $modules ) = @_;

    require Blender::Logger;
    my $logfile = Blender::Logger->logfile;

    my $start_msg = "-----> Start install modules for '$self->{name}'.";
    Blender::Message->notify( $start_msg );

    foreach my $name ( sort keys %{ $modules } ) {

        my $module = $self->module( $name, $modules->{$name} );
        my $cmd = $self->install_command( $module );

        Blender::Message->notify( "-----> $cmd" );
        system( "$cmd >> $logfile 2>&1" );

        if ( $? >> 8 ) {
            my $err = "Build fail.Command:$cmd return code:" . ( $? >> 8 );
            die( Blender::Error->new( $err ));
        }

    }

    my $end_msg = "-----> Finish install modules for '$self->{name}'.";
    Blender::Message->notify( $end_msg );

    return $self;
}

sub module {
    my ( $self, $name, $version ) = @_;
}

sub install_command {
}

sub initialize {
    # virtual method
}

1;
