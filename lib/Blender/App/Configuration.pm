package Blender::App::Configuration;

use 5.012;
use warnings;

use File::Spec;
use autodie;
use Carp;

our $blendname = 'blendedenv';

our $config_ref;
our $rcfile_ref;

our $CONFIGURATIONFILE;

our $dirty;

sub is_dirty {
    return $dirty;
}

sub config {
    return $config_ref;
}

sub rcfile {
    return $rcfile_ref;
}

# method for only test.
sub destroy {
    undef $CONFIGURATIONFILE;
    
    undef $blendname;
    undef $dirty;

    undef $config_ref;
    undef $rcfile_ref;
}

sub _configuration_file_path {
    require Blender::Home;
    
    return File::Spec->catfile( Blender::Home->conf, 'blender.conf' );
}

sub read_file {
    my $pkg = shift;

    my $path = _configuration_file_path();

    return if ( ! -e $path );

    open my $fh, '<', $path;
    my $str = do { local $/; <$fh> };
    close $fh;

    eval $str;

    $blendname = $CONFIGURATIONFILE->{blendname};

    require Blender::Config;
    foreach my $name ( keys %{ $CONFIGURATIONFILE->{config} } ) {
        $config_ref->{$name} =
            Blender::Config->new( %{ $CONFIGURATIONFILE->{config}{$name} } );
    }

    require Blender::RcFile;
    foreach my $filename ( keys %{ $CONFIGURATIONFILE->{rcfile} } ) {
        $rcfile_ref->{$filename} =
            Blender::RcFile->new( %{ $CONFIGURATIONFILE->{rcfile}{$filename} });
    }

    return $blendname;
}

sub write_file {
   
    require Blender::Feature;
    return if Blender::Feature->is_deploy_mode;

    return unless is_dirty();

    $CONFIGURATIONFILE = {
        blendname   =>  $blendname,
        config      =>  {},
        rcfile      =>  {},
        format      =>  'v1.0',  # for future...configuration format version.
    };

    foreach my $name ( keys %{ $config_ref } ) {
        $CONFIGURATIONFILE->{config}{$name} = $config_ref->{$name}->serialize;
    }

    foreach my $filename ( keys %{ $rcfile_ref } ) {
        $CONFIGURATIONFILE->{rcfile}{$filename} =
            $rcfile_ref->{$filename}->serialize;
    }

    my $path = _configuration_file_path();

    require Data::Dumper;
    open my $fh, '>', $path;
    my $dump = Data::Dumper->new(
            [ $CONFIGURATIONFILE ],
            [ 'Blender::App::Configuration::CONFIGURATIONFILE' ]
            );
    print $fh $dump->Dump;
    close $fh;

    return $blendname;
}

sub set_config {
    my ( $pkg, $config ) = @_;

    my $name = $config->name;
    $config_ref->{$name} = $config;

    $dirty++;

    return $config->name;
}

sub set_rcfile {
    my ( $pkg, $rcfile ) = @_;

    my $filename = $rcfile->filename;
    $rcfile_ref->{$filename} = $rcfile;

    $dirty++;

    return $rcfile->filename;
}

sub search_config {
    my ( $pkg, $name ) = @_;

    return $config_ref->{$name} if ( exists $config_ref->{$name} );
    return;
}

sub search_rcfile {
    my ( $pkg, $filename ) = @_;

    return $rcfile_ref->{$filename} if ( exists $rcfile_ref->{$filename} );
    return;
}

sub blendname {
    return $blendname;
}

sub set_blendname {
    my ( $pkg, $name ) = @_;

    $blendname = $name;

    return $blendname;
}

1;

