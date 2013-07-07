package Blender::Require;

use 5.012;
use warnings;

use Carp;

require Blender::Exception;
require Blender::Error;

sub try_require {
    my ( $pkg, $module ) = @_;

    unless ( $module ) {
        croak( Blender::Exception->new( "'$pkg' requires module name" ) );
    }

    my $path = $module . '.pm';
    $path =~ s{::}{/}g;

    eval { require $path };

    if ( $@ ) {
        die( Blender::Error->new( "Can't load module:$module" ) );
    }

    return $module;
}

1;
