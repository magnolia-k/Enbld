package Enbld::Target::Attribute::CommandConfigure;

use 5.012;
use warnings;

use parent qw/Enbld::Target::AttributeExtension::Command/;

sub validate {
    my ( $self, $string ) = @_;

    # nothing check now.

    return $string;
}

1;
