package Blender::Target::Attribute::DownloadSite;

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
    croak( Blender::Exception->new( "Attribute 'DownloadSite' isn't defined" ));
}

sub validate {
    my ( $self, $string ) = @_;

    $self->SUPER::validate( $string );

    return $string if ( $string =~ /\/$/ );

    my $err = "Attribute 'DownloadSite' does not end with slash character";
    require Blender::Exception;
    croak( Blender::Exception->new( $err, $string ));
}

1;
