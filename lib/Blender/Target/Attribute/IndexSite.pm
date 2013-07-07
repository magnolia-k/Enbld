package Blender::Target::Attribute::IndexSite;

use 5.012;
use warnings;

use Carp;

use parent qw/Blender::Target::AttributeExtension::URL/;

sub initialize {
    my ( $self, $param ) = @_;

    if ( ! defined $param ) {
        $self->{callback} = sub {
            return $self->{attributes}->DownloadSite;
        };

        return $self;
    }

    if ( $param ) {
        $self->SUPER::initialize( $param );
        return $self;
    }

    require Blender::Exception;
    croak( Blender::Exception->new( "Attribute 'IndexSite' isn't defined" ) );
}

1;
