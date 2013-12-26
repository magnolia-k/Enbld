package Enbld::Target::Attribute::CommandInstall;

use strict;
use warnings;

use parent qw/Enbld::Target::AttributeExtension::Command/;

sub initialize {
    my ( $self, $param ) = @_;

    if ( ! defined $param ) {
        my $make;
        if ( `make -v` =~ /GNU Make/ ) {
            $make = 'make';
        } elsif ( `which gmake` ) {
            $make = 'gmake';
        } else {
            require Enbld::Error;
            die( Enbld::Error->new( "GNU Make is NOT installed." ));
        }

        $self->{callback} = sub {
            return $make . ' install';
        };

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
