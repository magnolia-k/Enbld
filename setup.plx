#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use File::Spec;

main() unless caller();

sub main {

    check_env();

    my $home = $ENV{PERL_BLENDER_HOME} ? $ENV{PERL_BLENDER_HOME} :
        File::Spec->catdir( $ENV{HOME}, 'blended' );

    print "=====> Install Blender-Declare to $home.\n";

    install_app( $home );

    print "=====> Finish installation.\n";

    print "Please add following path to PATH.\n";
    print "\n";
    print " " x 4 . $home . '/Blender-Declare/bin' . "\n";
    print " " x 4 . $home . '/bin' . "\n";
    print "\n";
    print "Please add following path to MAN.\n";
    print "\n";
    print " " x 4 . $home . '/share/man' . "\n";
    print "\n";
}

sub check_env {

    # OS X check
    if ( $^O ne 'darwin' ) {
        die "Sorry, Blender-Declare is executable on OS X only.\n";
    }

    # perl version check
    if ( $] < '5.012' ) {
        die "Sorry, Blender-Declare requires perl 5.12.0 or above.\n";
    }
}

sub install_app {
    my $home = shift;

    print "-----> Install Blender-Declare's files.\n";

    my $dir = $FindBin::Bin;
    my $app_install = File::Spec->catdir( $home, 'Blender-Declare' );

    system( '/usr/bin/perl', File::Spec->catfile( $dir, 'Build.PL' ));
    if ( $? >> 8 ) { die "Installing Blender-Declare fail!\n" }

    system( '/usr/bin/perl', File::Spec->catfile( $dir, 'Build' ));
    if ( $? >> 8 ) { die "Installing Blender-Declare fail!\n" }

    system(
            '/usr/bin/perl',
            File::Spec->catfile( $dir, 'Build' ),
            'install',
            '--install_base',
            $app_install
            );
    if ( $? >> 8 ) { die "Installing Blender-Declare fail!\n" }

    return $app_install
}
