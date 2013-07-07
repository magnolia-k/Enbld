package Blender::Target::AttributeExtension::Word;

use 5.012;
use warnings;

use parent qw/Blender::Target::Attribute/;

use Carp;

sub validate {
    my ( $self, $string ) = @_;

    $self->SUPER::validate( $string );

    if ( $string =~ /\s/ ) {
        my $type = ref( $self );
        $type =~ s/.*:://;
        require Blender::Exception;
        croak( Blender::Exception->new(
                    "Attribute '$type' includes space character", $string
                    ) );
    }

    return $string;
}

1;
