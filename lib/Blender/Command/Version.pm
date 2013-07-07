package Blender::Command::Version;

use 5.012;
use warnings;

use parent qw/Blender::Command/;

require Blender::Declare;

sub do {
    say "blender (Blender::Declare) $Blender::Declare::VERSION";
}

1;
