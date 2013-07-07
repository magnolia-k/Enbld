package Blender::Target::AttributeExtension::URL;

use 5.012;
use warnings;

use Carp;

use parent qw/Blender::Target::AttributeExtension::Word/;

sub validate {
    my ( $self, $string ) = @_;

    $self->SUPER::validate( $string );

    my $pattern = q{s?https?://[-_.!~*'()a-zA-Z0-9;/?:@&=+$,%#]+};

    if ( $string !~ /^$pattern$/ ) {
        my $type = ref( $self );
        $type =~ s/.*:://;
        require Blender::Exception;
        croak( Blender::Exception->new(
            "Attribute '$type' isn't valid URL string", $string
        ));
    }
}

1;

