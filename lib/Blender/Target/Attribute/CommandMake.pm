package Blender::Target::Attribute::CommandMake;

use 5.012;
use warnings;

use parent qw/Blender::Target::AttributeExtension::Command/;

sub validate {
    my ( $self, $string ) = @_;

    # nothing check now.

    return $string;
}

1;
