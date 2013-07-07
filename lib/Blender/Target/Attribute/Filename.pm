package Blender::Target::Attribute::Filename;

use 5.012;
use warnings;

use Carp;

use parent qw/Blender::Target::AttributeExtension::Word/;

sub initialize {
    my ( $self, $param ) = @_;

    if ( ! defined $param ) {
        $self->{callback} = sub {
            my $attributes = shift;

            my $filename = $attributes->ArchiveName . "-";
            $filename .= $attributes->Version . '.' . $attributes->Extension;

            return $filename;
        };

        return $self;
    }

    if ( $param ) {
        $self->SUPER::initialize( $param );
        return $self;
    }

    require Blender::Exception;
    croak( Blender::Exception->new( "Attribute 'Filename' isn't defined" ) );
}

1;
