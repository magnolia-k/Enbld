package Enbld::Catchme;

use 5.012;
use warnings;

require Exporter;
our @ISA       = qw/Exporter/;
our @EXPORT    = qw/catchme/;

use Carp;

sub catchme($&) {

    return 1 unless $@;

    my $exception = $@;

    my $types   = shift;
    my $coderef = shift;

    if ( ! ref( $types ) ) {
        $types = [ $types ];
    }

    if ( grep { $exception->isa( $_ ) } @{ $types } ) {

       local $@ = $exception;
       $coderef->();

    } else {

        die $exception;

    }
}

1;
