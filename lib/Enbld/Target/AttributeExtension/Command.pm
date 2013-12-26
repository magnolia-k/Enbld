package Enbld::Target::AttributeExtension::Command;

use strict;
use warnings;

use parent qw/Enbld::Target::Attribute/;

our $make;
sub make_command {
    return $make if $make;

    if ( `make -v` =~ /GNU Make/ ) {
        return ( $make = 'make' );
    } elsif ( `which gmake` ) {
        return ( $make = 'gmake' );
    } else {
        require Enbld::Error;
        die( Enbld::Error->new( 'GNU Make is NOT installed' ));
    }
}

1;
