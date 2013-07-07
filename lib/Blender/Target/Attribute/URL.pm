package Blender::Target::Attribute::URL;

use 5.012;
use warnings;

use Carp;

use parent qw/Blender::Target::AttributeExtension::URL/;

sub initialize {
    my ( $self, $param ) = @_;

    if ( ! defined $param ) {
        $self->{callback} = sub {
            my $attributes = shift;

            return $attributes->DownloadSite . $attributes->Filename;
        };

        return $self;
    }

    if ( $param ) {
        $self->SUPER::initialize( $param );
        return $self;
    }

    require Blender::Exception;
    croak( Blender::Exception->new( "Attribute 'URL' isn't defined" ) );
}

1;
