package Test::Blender::Definition;

use strict;
use warnings;

use File::Temp;
use File::Spec;
use File::Path qw/make_path/;
use File::Copy;
use FindBin;

use Test::Builder::Module;
require Blender::Logger;
require Blender::Target;

my $CLASS = __PACKAGE__;

use parent qw/Test::Builder::Module/;

our @EXPORT = qw/build_ok/;

sub build_ok($$;$) {
    my $name        = $_[0];
    my $ver         = $_[1];
    my $description = $_[2];

    local $ENV{PERL_BLENDER_HOME} = File::Temp->newdir;
    require Blender::Home;
    Blender::Home->initialize;
    Blender::Home->create_build_directory;

    my $path = File::Spec->catdir( Blender::Home->home, 'bin' );
    local $ENV{PATH} = $path . ':' . $ENV{PATH};

    require Blender::Logger;
    Blender::Logger->rotate( Blender::Home->log );

    my $target = Blender::Target->new( $name );

    require Blender::Condition;
    my $condition = Blender::Condition->new( name => $name, version => $ver );

    $target->{attributes}->add( 'VersionCondition', $ver );
    
    eval {
        $target->_build( $condition );
    };

    my $tb = $CLASS->builder;

    chdir $FindBin::Bin;

    if ( $@ ) {
        my $logfile = File::Spec->catfile( $FindBin::Bin, time . 'log.txt' );
        $tb->diag( "copy logfile:" . $logfile );
        copy( Blender::Logger->logfile, $logfile );
        return $tb->BAIL_OUT( $@ );
    }

    return $tb->ok(@_);
}

1;


