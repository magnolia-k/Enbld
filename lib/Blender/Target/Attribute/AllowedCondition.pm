package Blender::Target::Attribute::AllowedCondition;

use 5.012;
use warnings;

use parent qw/Blender::Target::AttributeExtension::Word/;

sub is_omitable {
    return 1;
}

1;
