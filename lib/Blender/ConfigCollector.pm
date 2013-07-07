package Blender::ConfigCollector;

use 5.012;
use warnings;

use File::Spec;
use autodie;
use Carp;

our $blend_name = 'blendedenv';
our %collection;
our $CONFIGFILE;

our $dirty;

sub collection {
    return $collection{target};
}

sub destroy {
    # method for only test code.
    undef $CONFIGFILE;
    undef %collection;
}

sub _create_config_file_path {
    require Blender::Home;
    my $conf_path = File::Spec->catfile( Blender::Home->conf, 'blender.conf' );

    return $conf_path;
}

sub read_configuration_file {
    my $pkg = shift;

    my $conf_path = _create_config_file_path();

    return if ( ! -e $conf_path );

    open my $fh, '<', $conf_path;
    my $conf_string = do { local $/; <$fh> };
    close $fh;

    eval $conf_string;

    $blend_name = $CONFIGFILE->{blendname};

    require Blender::Config;
    foreach my $name ( keys %{ $CONFIGFILE->{target} } ) {
        $collection{target}{$name} =
            Blender::Config->new( %{ $CONFIGFILE->{target}{$name} } );
    }

    return $blend_name;
}

sub write_configuration_file {

    return unless $dirty;

    $CONFIGFILE = {
        blendname => $blend_name,
        target => {},
    };

    foreach my $name ( keys %{ $collection{target} } ) {
        $CONFIGFILE->{target}{$name} = $collection{target}->{$name}->serialize;
    }

    my $conf_path = _create_config_file_path();

    require Data::Dumper;
    open my $fh, '>', $conf_path;
    my $dump = Data::Dumper->new(
            [ $CONFIGFILE ], [ 'Blender::ConfigCollector::CONFIGFILE' ]
            );
    print $fh $dump->Dump;
    close $fh;

    return $blend_name;
}

sub set {
    my ( $self, $config ) = @_;
  
    if ( ! $config ) {
        require Blender::Exception;
        croak( Blender::Exception->new( "set method requires config object" ) );
    }

    $collection{target}->{$config->name} = $config;

    $dirty++;

    return $self;
}

sub search {
    my ( $pkg, $name ) = @_;

    return unless $name;

    if ( exists $collection{target}->{$name} ) {
        return $collection{target}->{$name};
    }

    return;
}

sub set_blend_name {
    my ( $pkg, $name ) = @_;

    if ( $blend_name ne $name ) {
        $blend_name = $name;
        $dirty++;
    }

    return $blend_name;
}

sub blend_name {
    return $blend_name;
}

1;
