package Enbld::Command::Version;

use strict;
use warnings;

use parent qw/Enbld::Command/;

require Enbld;

sub do {
    say "enbld (Enbld) $Enbld::VERSION";
}

1;
