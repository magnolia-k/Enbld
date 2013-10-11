package Enbld::Command::Tutorial;

use 5.012;
use warnings;

use File::Spec;

use parent qw/Enbld::Command/;

sub do {

    my $module_path = $INC{'Enbld/Command.pm'};
    $module_path =~ s{/Command.pm$}{};

    my $path = File::Spec->catfile( $module_path, 'Tutorial.pm' );

    system ( 'perldoc', $path );

    return $_[0];
}

1;
