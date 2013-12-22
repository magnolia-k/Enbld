package Enbld::Target::Attribute::Dependencies;

use strict;
use warnings;

use Carp;

use parent qw/Enbld::Target::AttributeExtension::Word/;

sub validate {
    my ( $self, $value ) = @_;

    unless ( ref( $value ) eq 'ARRAY' ) {
        my $type = ref( $self );
        $type =~ s/.*:://;

        my $err = "Attribute 'Dependencies' isn't ARRAY reference";
        require Enbld::Exception;
        croak( Enbld::Exception->new( $err, $value ));
    }

    foreach my $string ( @{ $value } ) {
        $self->SUPER::validate( $string );
    }

    return $value;
}

sub to_value {
    my $self = shift;

    my $value = $self->evaluate;

    return [] if ( ! defined $value );

    $self->validate( $value );

    return $value;
}

1;
