package Blender::Command::Usage;

use 5.012;
use warnings;

use parent qw/Blender::Command/;

sub do {
    say "try 'blender help' for more information.";
}

1;
