package Blender::Target::Attribute::DistName;

use 5.012;
use warnings;

use Carp;

use parent qw/Blender::Target::AttributeExtension::Word/;

sub initialize {
    my ( $self, $param ) = @_;

    if ( ! defined $param ) {
        $self->{callback} = sub {
            return $self->{attributes}->ArchiveName;
        };

        return $self;
    }

    if ( $param ) {
        $self->SUPER::initialize( $param );
        return $self;
    }

    require Blender::Exception;
    croak( Blender::Exception->new( "Attribute 'DistName' isn't defined" ) );
}

1;
