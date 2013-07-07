package Blender::Target::AttributeExtension::RegEx;

use 5.012;
use warnings;

use Carp;

use parent qw/Blender::Target::Attribute/;

sub validate {
    my ( $self, $string ) = @_;

    $self->SUPER::validate( $string );

    eval { "" =~ /$string/ };

    if ( $@ ) {
        my $type = ref( $self );
        $type =~ s/.*:://;

        require Blender::Exception;
        croak( Blender::Exception->new(
                "Attribute '$type' is NOT valid regular expression string",
                $string
                    ) );
    }

    return $string;
}

1;
