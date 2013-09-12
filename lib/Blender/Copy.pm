package Blender::Copy;

use 5.012;
use warnings;

use autodie;
use Carp;

require Exporter;
our @ISA    = qw/Exporter/;
our @EXPORT = qw/recursive_copy/;

use File::Find;
use File::Path qw/make_path/;
use File::Copy qw/cp/;

our $dir_from;
our $dir_to;
sub recursive_copy {
    $dir_from = shift;
    $dir_to   = shift;

    unless ( -d $dir_from ) {
        croak( "'$dir_from' is not directory." );
    }

    if ( -e $dir_to ) {
        croak( "$dir_to' exists already." );
    }

    find( \&file_copy, $dir_from );
}

sub file_copy {
    my $file_from = $_;

    my $file_to = $File::Find::name;
    $file_to =~ s/^$dir_from/$dir_to/;

    if ( -d $file_from) {
        make_path $file_to;
    } else {
        cp( $file_from, $file_to );
    }
}

1;
