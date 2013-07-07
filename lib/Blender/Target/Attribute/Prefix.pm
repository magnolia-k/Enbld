package Blender::Target::Attribute::Prefix;

use 5.012;
use warnings;

use Carp;

use parent qw/Blender::Target::AttributeExtension::Word/;

sub initialize {
    my ( $self, $param ) = @_;

    if ( ! defined $param ) {
        $self->{value} = '--prefix=';
        $self->{is_evaluated}++;

        return $self;
    }

    if ( $param ) { 
        $self->SUPER::initialize( $param );
        return $self;
    }

    require Blender::Exception;
    croak( Blender::Exception->new( "Attribute 'Prefix' isn't defined" ) );
}

1;
