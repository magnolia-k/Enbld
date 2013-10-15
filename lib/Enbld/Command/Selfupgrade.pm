package Enbld::Command::Selfupgrade;

use 5.012;
use warnings;

use File::Spec;

use parent qw/Enbld::Command/;

sub do {
    my $cpanm = File::Spec->catfile( $ENV{HOME}, '.enbld', 'etc', 'cpanm' );

    download_cpanm() unless ( -e $cpanm );

    say "=====> Upgrade Enbld.";

    my $location = File::Spec->catdir( $ENV{HOME}, '.enbld', 'extlib' );
    system( '/usr/bin/perl', $cpanm, 'Enbld', '-L', $location );

    say "=====> Finish upgrade.";

    return $_[0];
}

sub download_cpanm {
    $File::Fetch::BLACKLIST = [ qw|lwp httptiny| ];

    my $ff       = File::Fetch->new( uri => 'http://xrl.us/cpanm' );
    my $location = File::Spec->catdir( $ENV{HOME}, '.enbld', 'etc' );
    my $where    = $ff->fetch( to => $location ) or die $ff->error;

    return $where;
}

1;
