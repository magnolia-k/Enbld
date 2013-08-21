package Blender::Home;

use 5.012;
use warnings;

use Carp;
use File::Spec;
use File::Path qw/make_path remove_tree/;
use autodie;
use Time::Piece;
use Time::Seconds;

require Blender::Feature;
require Blender::Error;
require Blender::Exception;

our $dirs = {
    home        =>  undef,
    dists       =>  undef,
    depository  =>  undef,
    build       =>  undef,
    conf        =>  undef,
    etc         =>  undef,
    log         =>  undef,
    library     =>  undef,
    deploy_path =>  undef,
};

sub initialize {
    my $pkg = shift;

    $pkg->_create_home_directory;
    $pkg->_set_deploy_directory if Blender::Feature->is_deploy_mode;
	$pkg->_delete_old_build_directory;

    return $dirs->{home};
}

sub AUTOLOAD {
    my $method = our $AUTOLOAD;
    $method =~ s/.*:://;

    unless ( exists $dirs->{$method} ) {
        my $err = "Can't execute Blender::Home's method.";
        croak( Blender::Exception->new( $err, $method ));
    }

    unless ( $dirs->{$method} ) {
        my $err = "Not initialized blender home's path yet.";
        croak( Blender::Exception->new( $err ));
    }

    return $dirs->{$method};
}

sub create_build_directory {

    make_path( $dirs->{build} = File::Spec->catdir(
                $dirs->{home}, 'build', time
                ));

    return $dirs->{build};
}

sub install_path {

    return Blender::Home->deploy_path if Blender::Feature->is_deploy_mode;
    return Blender::Home->home;

}

sub _create_home_directory {
    my $pkg = shift;

    $dirs->{home} = $ENV{PERL_BLENDER_HOME} ? $ENV{PERL_BLENDER_HOME} :
        File::Spec->catdir( $ENV{HOME}, 'blended' );

    my $error;
    make_path( $dirs->{home}, { error => \$error } );

    if ( @{ $error } ) {
        die( Blender::Error->new(
                    "Can't create blender's home directory:$dirs->{home}\n" .
                    "Please check write permission for $dirs->{home}",
                    ));
    }

    if ( ! -w $dirs->{home} ) {
        die( Blender::Error->new(
                    "No permission to write directory:$dirs->{home}" .
                    "Please check write permission for $dirs->{home}"
                    ));
    }

    make_path( $dirs->{$_} = File::Spec->catdir( $dirs->{home}, $_ )) for
        qw/dists build depository conf etc log/;

    $dirs->{library} = $dirs->{home};

    return $dirs->{home};
}

sub _set_deploy_directory {

    my $deploy_path = Blender::Feature->deploy_path;

    $dirs->{deploy_path}    = $deploy_path;
    $dirs->{library}        = $deploy_path;

    return $dirs->{deploy_path};
}

sub _delete_old_build_directory {

	opendir my $dh, $dirs->{build};
	my @list = grep { !/^\.{1,2}$/ } readdir $dh;
	closedir $dh;

	my $limit = localtime;
	$limit -= ONE_MONTH;

	foreach my $build_dir ( @list ) {
		if ( $limit->epoch > $build_dir ) {
			remove_tree( File::Spec->catdir( $dirs->{build}, $build_dir ) );
		}
	}
}

1;
