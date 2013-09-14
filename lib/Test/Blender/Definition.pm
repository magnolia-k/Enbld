package Test::Blender::Definition;

use strict;
use warnings;

use Test::Builder::Module;

use File::Temp;
use File::Spec;
use File::Path qw/make_path/;
use File::Copy;
use FindBin;

require Blender::Home;
require Blender::Logger;
require Blender::Target;
require Blender::Condition;

my $CLASS = __PACKAGE__;

use parent qw/Test::Builder::Module/;

our @EXPORT = qw/build_ok/;

sub build_ok($;$$$) {
    my $name        = $_[0];
    my $config      = $_[1];
    my $condition   = $_[2];
    my $description = $_[3];

    local $ENV{PERL_BLENDER_HOME} = File::Temp->newdir;

    Blender::Home->initialize;
    Blender::Home->create_build_directory;

    Blender::Logger->rotate( Blender::Home->log );

    my $target = Blender::Target->new( $name, $config );

    my $installed;
    if ( $condition ) {
        eval { $installed = $target->install_declared( $condition ) };
    } else {
        eval { $installed = $target->install };
    }

    my $tb = $CLASS->builder;

    chdir $FindBin::Bin;

    if ( $@ ) {
        $tb->diag( "Error occured, please check logfile." );

        my $logfile = File::Spec->catfile(
                $FindBin::Bin,
                'build_' . time . '_log.txt'
                );
        $tb->diag( "logfile:" . $logfile );
        copy( Blender::Logger->logfile, $logfile );

        return $tb->BAIL_OUT( $@ );
    }

    return $tb->ok(@_);
}

1;
