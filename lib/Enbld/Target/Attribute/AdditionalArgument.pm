package Enbld::Target::Attribute::AdditionalArgument;

use strict;
use warnings;

use parent qw/Enbld::Target::AttributeExtension::Command/;

sub is_omitable {
    return 1;
}

1;
