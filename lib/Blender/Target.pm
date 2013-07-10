package Blender::Target;

use 5.012;
use warnings;

use Carp;

use version;

use File::Spec;
use File::Path qw/make_path remove_tree/;
use File::Find;
use autodie;

require Blender::Feature;
require Blender::Condition;
require Blender::Message;
require Blender::Home;
require Blender::HTTP;
require Blender::Target::Symlink;
require Blender::Error;
require Blender::Exception;

sub new {
    my ( $class, $name, $config ) = @_;

    unless ( $name ) {
        croak( Blender::Exception->new( "'$class' require name" ) );
    }

    my $self = {
        name        =>  $name,
        config      =>  $config,
        attributes  =>  undef,
        build       =>  undef,
        install     =>  undef,
        PATH        =>  undef,
    };

    bless $self, $class;

    $self->_set_config;
    $self->_set_attributes;
    $self->_set_PATH;

    return $self;
}

sub install {
    my $self = shift;
    
    if ( ! $self->_is_install_ok ) {
        die( Blender::Error->new( "'$self->{name}' is already installed" ) );
    }

    my $condition = Blender::Condition->new( name => $self->{name} );

    $self->{attributes}->add( 'VersionCondition', $condition->version );
    $self->_build( $condition );

    return $self->{config};
}

sub _is_install_ok {
    my $self = shift;

    return $self if Blender::Feature->is_deploy_mode;
    return $self if Blender::Feature->is_force_install;
    return if $self->is_installed;
    return $self;
}

sub install_declared {
    my $self = shift;
    my $condition = shift;

    $self->{attributes}->add( 'VersionCondition', $condition->version );

    return unless $self->_is_install_declared_ok( $condition );

    $self->_build( $condition );

    return $self->{config};
}

sub _is_install_declared_ok {
    my ( $self, $condition ) = @_;

    return $self if Blender::Feature->is_deploy_mode;
    return $self if Blender::Feature->is_force_install;
    return $self unless $self->{config}->enabled;
    return $self unless $condition->is_equal_to( $self->{config}->condition );
    return if $self->{config}->enabled eq $self->{attributes}->Version;

    return $self;
}

sub upgrade {
    my $self = shift;

    if ( ! $self->is_installed ) {
        die( Blender::Error->new( "'$self->{name}' is not installed yet" ) );
    }

    $self->{attributes}->add(
            'VersionCondition',
            $self->{config}->condition->version
            );

    my $newest = $self->{attributes}->Version;
    my $enabled = $self->{config}->enabled;

    if ( version->declare( $newest ) <= version->declare( $enabled ) ) {
        die( Blender::Error->new( "'$self->{name}' is up to date" ) );
    }

    # if test option is set, condition is overwrited.
    $self->{config}->condition->set_make_test(
            Blender::Feature->is_make_test_all
            );

    $self->_build( $self->{config}->condition );

    return $self->{config};
}

sub off {
    my $self = shift;

    if ( ! $self->is_installed ) {
        require Blender::Error;
        die( Blender::Error->new( "'$self->{name}' is not installed yet" ) );
    }

    $self->_drop;

    $self->{config}->drop_enabled;

    return $self->{config};
}

sub use {
    my ( $self, $version ) = @_;

    my $form = $self->{attributes}->VersionForm;
    if ( $version !~ /^$form$/ ) {
        die( Blender::Error->new( "'$version' is not valid version form" ) );
    }

    if ( $self->{config}->enabled && $self->{config}->enabled eq $version ) {
        die( Blender::Error->new( "'$version' is current enabled version" ) );
    }

    if ( $self->{config}->is_installed_version( $version ) ) {
        $self->_switch( $version );

        return $self->{config};
    }

    die( Blender::Error->new( "'$version' isn't installed yet" ) );
}

sub is_installed {
    my $self = shift;

    return $self->{config}->enabled;
}

sub is_outdated {
    my $self = shift;

    return unless ( $self->{config}->enabled );

    $self->{attributes}->add(
            'VersionCondition', $self->{config}->condition->version
            );

    my $newest = $self->{attributes}->Version;
    my $enabled = $self->{config}->enabled;

    if ( version->declare( $newest ) > version->declare( $enabled ) ) {
        return $newest;
    }

    return;
}

sub _set_config {
    my $self = shift;

    if ( ! $self->{config} ) {
        require Blender::Config;
        $self->{config} = Blender::Config->new( name => $self->{name} );
    }
}

sub _set_attributes {
    my $self = shift;

    if ( $self->{name} =~ /[^a-z0-9]/ ) {
        die( Blender::Error->new( "invalid target name '$self->{name}'" ));
    }

    my $module = 'Blender::Definition::' . ucfirst( $self->{name} );

    require Blender::Require;
    eval { Blender::Require->try_require( $module ) };

    if ( $@ ) {
        die( Blender::Error->new( "no definition for target '$self->{name}'" ));
    }

    $self->{attributes} = $module->new->parse;
}

sub _set_PATH {
    my $self = shift;

    my $path = File::Spec->catdir( Blender::Home->install_path, 'bin' );

    $self->{PATH} = $path . ':' . $ENV{PATH};
}

sub _switch {
    my ( $self, $version ) = @_;

    my $path = File::Spec->catdir(
            Blender::Home->depository,
            $self->{attributes}->DistName
            );

    my $new = File::Spec->catdir( $path, $version );

    Blender::Target::Symlink->delete_symlink( $path );
    Blender::Target::Symlink->create_symlink( $new );

    $self->{config}->set_enabled(
            $version,
            $self->{config}->condition( $version ),
            );
}

sub _drop {
    my $self = shift;

    my $path = File::Spec->catdir(
            Blender::Home->depository,
            $self->{attributes}->DistName,
            );

    Blender::Target::Symlink->delete_symlink( $path );

    $self->{config}->drop_enabled;
}

sub _build {
    my ( $self, $condition ) = @_;

    Blender::Message->notify( "=====> Start building target '$self->{name}'." );

    local $ENV{PATH} = $self->{PATH};

    $self->_solve_dependencies;

    $self->_setup_build_directory;
    $self->_setup_install_directory;

    chdir $self->{build};

    $self->_prebuild;

    $self->_configure;
    $self->_make;

    if ( $condition->make_test or Blender::Feature->is_make_test_all ) {
        $self->_test;
    }

    $self->_install;

    $self->_postbuild;

    $self->_install_module( $condition ) if $condition->modules;

    my $finish_msg = "=====> Finish building target '$self->{name}'.";
    Blender::Message->notify( $finish_msg );

    $self->{config}->set_enabled( $self->{attributes}->Version, $condition );

    if ( $condition->modules ) {
        $self->{config}->set_modules( $condition->modules );
    }
}

sub _solve_dependencies {
    my $self = shift;

    return if ( ! @{ $self->{attributes}->Dependencies } );

    Blender::Message->notify( "=====> Found dependencies." );

    require Blender::ConfigCollector;
    require Blender::ConditionCollector;

    foreach my $dependency ( @{ $self->{attributes}->Dependencies } ) {

        Blender::Message->notify( "-----> Dependency '$dependency'." );

        my $config = Blender::ConfigCollector->search( $dependency );
        my $target = Blender::Target->new( $dependency, $config );

        if ( ( ! Blender::Feature->is_deploy_mode ) && $target->is_installed ) {
            my $installed_msg = "-----> $dependency is already installed.";
            Blender::Message->notify( $installed_msg );
            next;
        }

        Blender::Message->notify( "-----> $dependency is not installed yet. " );
 
        my $condition = Blender::ConditionCollector->search( $dependency );

        my $installed;
        if ( $condition ) {
            $installed = $target->install_declared( $condition );
        } else {
            $installed = $target->install;
        }

        Blender::ConfigCollector->set( $installed );
    }
}

sub _prebuild {
    my $self = shift;

    $self->_apply_patchfiles if $self->{attributes}->PatchFiles;
}

sub _configure {
    my $self = shift;

    return $self unless $self->{attributes}->CommandConfigure;

    my $configure;

    $configure = $self->{attributes}->CommandConfigure . ' ';
    $configure .= $self->{attributes}->Prefix . $self->{install};

    if( $self->{attributes}->AdditionalArgument ) {
        $configure .= ' ' . $self->{attributes}->AdditionalArgument;
    }

    $self->_exec( $configure );
}

sub _make {
    my $self = shift;

    if ( $self->{attributes}->CommandConfigure ) {
        $self->_exec( $self->{attributes}->CommandMake );
        return $self;
    }

    my $args = $self->{attributes}->Prefix . $self->{install};

    if ( $self->{attributes}->AdditionalArgument ) {
        $args .= ' ' . $self->{attributes}->AdditionalArgument;
    }

    $self->_exec( $self->{attributes}->CommandMake . ' ' . $args );

    return $self;
}

sub _test {
    my $self = shift;

    return $self unless $self->{attributes}->CommandTest;

    $self->_exec( $self->{attributes}->CommandTest );
}

sub _install {
    my $self = shift;

    if ( $self->{attributes}->CommandConfigure ) {
        $self->_exec( $self->{attributes}->CommandInstall );
        return $self;
    }

    my $args = $self->{attributes}->Prefix . $self->{install};

    if ( $self->{attributes}->AdditionalArgument ) {
        $args .= ' ' . $self->{attributes}->AdditionalArgument;
    }

    $self->_exec( $self->{attributes}->CommandInstall . ' ' . $args );

    return $self;
}

sub _install_module {
    my ( $self, $condition ) = @_;

    unless ( Blender::Feature->is_deploy_mode ) {
        my $module_path = File::Spec->catdir(
                Blender::Home->modules,
                $self->{attributes}->ArchiveName,
                $self->{attributes}->Version,
                );

        remove_tree( $module_path ) if ( -d $module_path );
    }

    require Blender::Module;
    my $module = Blender::Module->new( name => $self->{name} );

    $module->install( $condition->modules );
}

sub _postbuild {
    my $self = shift;

    if ( Blender::Feature->is_deploy_mode ) {
        return;
    }

    my $path = File::Spec->catdir(
            Blender::Home->depository,
            $self->{attributes}->DistName,
            );

    Blender::Target::Symlink->delete_symlink( $path );
    Blender::Target::Symlink->create_symlink( $self->{install} );
}

sub _exec {
    my ( $self, $cmd ) = @_;

    require Blender::Logger;
    my $logfile = Blender::Logger->logfile;

    Blender::Message->notify( "-----> $cmd" );

    system( "$cmd >> $logfile 2>&1" );

    if ( $? >> 8 ) {
        my $err = "Build fail.Command:$cmd return code:" . ( $? >> 8 );
        die( Blender::Error->new( $err ));
    }
}

sub _apply_patchfiles {
    my $self = shift;

    my $patchfiles = $self->{attributes}->PatchFiles;

    require Blender::HTTP;
    require Blender::Message;
    require Blender::Logger;
    my $logfile = Blender::Logger->logfile;
    foreach my $patchfile ( @{ $patchfiles } ) {
        my @parse = split( /\//, $patchfile );
        my $path = File::Spec->catfile( $self->{build}, $parse[-1] );

        Blender::HTTP->new( $patchfile )->download( $path );
        Blender::Message->notify( "-----> Apply patch $parse[-1]." );

        system( "patch -p0 < $path >> $logfile 2>&1" );
    }
}

sub _setup_build_directory {
    my $self = shift;
    
    my $path = File::Spec->catfile(
            Blender::Home->dists,
            $self->{attributes}->Filename
            );

    my $http = Blender::HTTP->new( $self->{attributes}->URL );
    my $archivefile = $http->download_archivefile( $path );
    my $build = $archivefile->extract( Blender::Home->build );

    $self->{build} = $build;
}

sub _setup_install_directory {
    my $self = shift;
  
    if ( Blender::Feature->is_deploy_mode ) {
        $self->{install} = Blender::Home->deploy_path;
        return $self->{install};
    }

    my $depository = File::Spec->catdir(
            Blender::Home->depository,
            $self->{attributes}->DistName,
            $self->{attributes}->Version,
            );

    if ( -d $depository ) {
        remove_tree( $depository );
    }

    return ( $self->{install} = $depository );
}

1;
