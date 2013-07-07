package Blender::Target::Attribute::WebSite;

use 5.012;
use warnings;

use Carp;

use parent qw/Blender::Target::AttributeExtension::URL/;

sub initialize {
    my ( $self, $param ) = @_;

    if ( $param ) {
        $self->SUPER::initialize( $param );
        return $self;
    }

    require Blender::Exception;
    croak( Blender::Exception->new( "Attribute 'WebSite' isn't defined" ));
}

1;
