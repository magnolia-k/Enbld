package Blender::Target;

use 5.012;
use warnings;

use Carp;

use version;

use File::Spec;
use File::Path qw/make_path remove_tree/;
use File::Find;
use autodie;

require Blender::Definition;
require Blender::Feature;
require Blender::Condition;
require Blender::Message;
require Blender::Home;
require Blender::HTTP;
require Blender::Target::Symlink;
require Blender::Error;
require Blender::Deployed;

sub new {
    my ( $class, $name, $config ) = @_;

    my $self = {
        name       =>  $name,
        config     =>  $config,
        attributes =>  undef,
        build      =>  undef,
        install    =>  undef,
        PATH       =>  undef,
        conditions =>  undef,
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
        die( Blender::Error->new( "'$self->{name}' is already installed." ) );
    }

    my $condition = Blender::Condition->new;

    $self->{attributes}->add( 'VersionCondition', $condition->version );

    $self->_build( $condition );

    return $self->{config};
}

sub _is_install_ok {
    my $self = shift;

    return 1 if Blender::Feature->is_force_install;
    return if $self->is_installed;
    return 1;
}

sub deploy {
    my $self = shift;

    my $condition = Blender::Condition->new;

    $self->{attributes}->add( 'VersionCondition', $condition->version );

    $self->_build_to_deploy( $condition );

    return $self->{config};
}

sub install_declared {
    my ( $self, $declared_conditions ) = @_;

    $self->{attributes}->add(
            'VersionCondition',
            $declared_conditions->{$self->{name}}{version}
            );

    return unless $self->_is_install_declared_ok(
            $declared_conditions->{$self->{name}}
            );

    $self->{conditions} = $declared_conditions;

    $self->_build( $declared_conditions->{$self->{name}} );

    return $self->{config};
}

sub deploy_declared {
    my ( $self, $declared_conditions ) = @_;

    $self->{attributes}->add(
            'VersionCondition',
            $declared_conditions->{$self->{name}}{version}
            );

    $self->{conditions} = $declared_conditions;

    $self->_build_to_deploy( $declared_conditions->{$self->{name}} );

    return $self->{config};
}

sub _is_install_declared_ok {
    my ( $self, $condition ) = @_;

    return 1 if Blender::Feature->is_force_install;
    return 1 unless $self->{config}->enabled;
    return 1 unless $condition->is_equal_to( $self->{config}->condition );
    return if $self->{config}->enabled eq $self->{attributes}->Version;

    return 1;
}

sub upgrade {
    my $self = shift;

    if ( ! $self->is_installed ) {
        die( Blender::Error->new( "'$self->{name}' is not installed yet." ) );
    }

    $self->{attributes}->add(
            'VersionCondition',
            $self->{config}->condition->version
            );

    my $current = $self->{attributes}->Version;
    my $enabled = $self->{config}->enabled;

    if ( version->declare( $current ) <= version->declare( $enabled ) ) {
        die( Blender::Error->new( "'$self->{name}' is up to date." ) );
    }

    $self->_build( $self->{config}->condition );

    return $self->{config};
}

sub off {
    my $self = shift;

    if ( ! $self->is_installed ) {
        die( Blender::Error->new( "'$self->{name}' is not installed yet." ) );
    }

    $self->_drop;

    $self->{config}->drop_enabled;

    return $self->{config};
}

sub rehash {
    my $self = shift;

    if ( ! $self->is_installed ) {
        die( Blender::Error->new( "'$self->{name}' isn't installed yet." ) );
    }

    $self->_switch( $self->{config}->enabled );

    return $self->{config};
}

sub use {
    my ( $self, $version ) = @_;

    if ( ! $self->is_installed ) {
        die( Blender::Error->new( "'$self->{name}' isn't installed yet." ) );
    }

    my $form = $self->{attributes}->VersionForm;
    if ( $version !~ /^$form$/ ) {
        die( Blender::Error->new( "'$version' is not valid version form." ) );
    }

    if ( $self->{config}->enabled && $self->{config}->enabled eq $version ) {
        die( Blender::Error->new( "'$version' is current enabled version." ) );
    }

    if ( ! $self->{config}->is_installed_version( $version ) ) {
        die( Blender::Error->new( "'$version' isn't installed yet" ) );
    }

    $self->_switch( $version );

    return $self->{config};
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

    my $current = $self->{attributes}->Version;
    my $enabled = $self->{config}->enabled;

    if ( version->declare( $current ) > version->declare( $enabled ) ) {
        return $current;
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

    $self->{attributes} = Blender::Definition->new( $self->{name} )->parse;
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

    $self->_setup_install_directory;
    $self->_exec_build_command( $condition );

    if ( $condition->modules ) {
        $self->_install_module( $condition );
    }

    $self->_postbuild;

    my $finish_msg = "=====> Finish building target '$self->{name}'.";
    Blender::Message->notify( $finish_msg );

    $self->{config}->set_enabled( $self->{attributes}->Version, $condition );
}

sub _build_to_deploy {
    my ( $self, $condition ) = @_;

    Blender::Message->notify( "=====> Start building target '$self->{name}'." );

    local $ENV{PATH} = $self->{PATH};

    $self->_solve_dependencies_to_deploy;

    $self->{install} = Blender::Home->deploy_path;

    $self->_exec_build_command( $condition );

    if ( $condition->modules ) {
        $self->_install_module( $condition );
    }

    my $finish_msg = "=====> Finish building target '$self->{name}'.";
    Blender::Message->notify( $finish_msg );

    $self->{config}->set_enabled( $self->{attributes}->Version, $condition );
}

sub _exec_build_command {
    my $self = shift;
    my $condition = shift;

    $self->_setup_build_directory;
    chdir $self->{build};

    $self->_prebuild;

    $self->_configure( $condition );
    $self->_make;

    if ( $condition->make_test or Blender::Feature->is_make_test_all ) {
        $self->_test;
    }

    $self->_install;
}

sub _solve_dependencies {
    my $self = shift;

    return if ( ! @{ $self->{attributes}->Dependencies } );

    Blender::Message->notify( "=====> Found dependencies." );

    require Blender::App::Configuration;

    foreach my $dependency ( @{ $self->{attributes}->Dependencies } ) {

        Blender::Message->notify( "--> Dependency '$dependency'." );

        my $config = Blender::App::Configuration->search_config( $dependency );
        my $target = Blender::Target->new( $dependency, $config );

        if ( $target->is_installed ) {
            my $installed_msg = "--> $dependency is already installed.";
            Blender::Message->notify( $installed_msg );
            next;
        }

        Blender::Message->notify( "--> $dependency is not installed yet." );

        my $condition = $self->{conditions}{$dependency} ?
            $self->{conditions}{$dependency} : undef;

        my $installed;
        if ( $condition ) {
            $installed = $target->install_declared( $self->{conditions} );
        } else {
            $installed = $target->install;
        }
        
        Blender::App::Configuration->set_config( $installed );
    }
}

sub _solve_dependencies_to_deploy {
    my $self = shift;

    return if ( ! @{ $self->{attributes}->Dependencies } );

    Blender::Message->notify( "=====> Found dependencies." );

    foreach my $dependency ( @{ $self->{attributes}->Dependencies } ) {

        next if ( Blender::Deployed->is_deployed( $dependency ));

        Blender::Message->notify( "--> Dependency '$dependency'." );
        Blender::Message->notify( "--> $dependency is not installed yet." );
 
        my $target = Blender::Target->new( $dependency );

        my $condition = $self->{conditions}{$dependency} ?
            $self->{conditions}{$dependency} : undef;

        my $installed;
        if ( $condition ) {
            $installed = $target->deploy_declared( $self->{conditions} );
        } else {
            $installed = $target->deploy;
        }

        Blender::Deployed->add( $installed );
    }
}

sub _prebuild {
    my $self = shift;

    $self->_apply_patchfiles if $self->{attributes}->PatchFiles;
}

sub _configure {
    my $self      = shift;
    my $condition = shift;

    return $self unless $self->{attributes}->CommandConfigure;

    my $configure;

    $configure = $self->{attributes}->CommandConfigure . ' ';
    $configure .= $self->{attributes}->Prefix . $self->{install};

    if( $self->{attributes}->AdditionalArgument ) {
        $configure .= ' ' . $self->{attributes}->AdditionalArgument;
    }

    if ( $condition->arguments ) {
        $configure .= ' ' . $condition->arguments;
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

    require Blender::Module;
    my $module = Blender::Module->new(
            name    => $self->{name},
            path    => $self->{install},
            );

    $module->install( $condition->modules );
}

sub _postbuild {
    my $self = shift;

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

    Blender::Message->notify( "--> $cmd" );

    system( "$cmd >> $logfile 2>&1" );

    return $self unless $?;

    if ( $? == -1 ) {
        die( Blender::Error->new( "Failed to execute:$cmd" ));
    } elsif ( $? & 127 ) {
        my $err = "Child died with signal:$cmd";
        die( Blender::Error->new( $err ));
    } else {
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
        Blender::Message->notify( "--> Apply patch $parse[-1]." );

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

    return ( $self->{build} = $build );
}

sub _setup_install_directory {
    my $self = shift;
  
    my $depository = File::Spec->catdir(
            Blender::Home->depository,
            $self->{attributes}->DistName,
            $self->{attributes}->Version,
            );

    remove_tree( $depository ) if ( -d $depository );

    return ( $self->{install} = $depository );
}

1;
