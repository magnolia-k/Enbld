package Blender::Message;

use 5.012;
use warnings;

our $VERBOSE;

sub notify {
    my ( $pkg, $msg ) = @_;

    chomp( $msg );
    $msg .= "\n";

    require Blender::Logger;
    Blender::Logger->write( $msg ) if Blender::Logger->logfile;
    
    print $msg if $VERBOSE;
}

sub alert {
    my ( $pkg, $msg ) = @_;

    chomp( $msg );
    $msg .= "\n";

    require Blender::Logger;
    Blender::Logger->write( $msg ) if Blender::Logger->logfile;
    
    print STDERR $msg if $VERBOSE;
}

sub set_verbose {
    $VERBOSE++;
}

1;

