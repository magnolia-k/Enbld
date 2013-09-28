package Enbld::Command::Usage;

use 5.012;
use warnings;

use parent qw/Enbld::Command/;

sub do {
    say "try 'enbld help' for more information.";
}

1;
