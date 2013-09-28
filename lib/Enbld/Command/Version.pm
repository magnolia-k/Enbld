package Enbld::Command::Version;

use 5.012;
use warnings;

use parent qw/Enbld::Command/;

require Enbld;

sub do {
    say "enbld (Enbld) $Enbld::VERSION";
}

1;
