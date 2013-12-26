package Enbld::Target::Attribute::CommandMake;

use strict;
use warnings;

use parent qw/Enbld::Target::AttributeExtension::Command/;

sub initialize {
    my ( $self, $param ) = @_;

    if ( ! defined $param ) {

        if ( `make -v` =~ /GNU Make/ ) {
            $self->{value} = 'make';
        } elsif ( `which gmake` ) {
            $self->{value} = 'gmake';
        } else {
            require Enbld::Error;
            die( Enbld::Error->new( "GNU Make is NOT installed." ));
        }

        $self->{is_evaluated}++;

        return $self;
    }

    if ( $param ) {
        $self->SUPER::initialize( $param );
        return $self;
    }

    # empty string is valid.
    $self->{is_evaluated}++;
}

sub validate {
    my ( $self, $string ) = @_;

    # nothing check now.

    return $string;
}

1;
