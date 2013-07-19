package Blender::Declare;

use 5.012;
use warnings;

use Getopt::Long;

our $VERSION = '0.6002';

require Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw/
    blend
    build
    target
    define
    version
    make_test
    modules
/;

require Blender::Logger;
require Blender::Target;
require Blender::ConfigCollector;
require Blender::Condition;
require Blender::Error;
require Blender::Exception;

our $condition;

sub blend($$) {
    parse_option();

    require Blender::Home;
    Blender::Home->initialize;

    require Blender::Message;
    Blender::Message->set_verbose;

    Blender::ConfigCollector->read_configuration_file;
    Blender::ConfigCollector->set_blend_name( $_[0] );

    $_[1]->();
    
    if ( ! Blender::Feature->is_deploy_mode ) {
        Blender::ConfigCollector->write_configuration_file;
    }

    return 1;
}

sub build(&) {
    return $_[0];
}

sub target($$) {

    Blender::Declare->_setup_directory;

    $condition = {
        name        =>  $_[0],
        version     =>  undef,
        make_test   =>  undef,
        modules     =>  undef,
    };

    my $config = Blender::ConfigCollector->search( $condition->{name} );

    $_[1]->();

    my $target = Blender::Target->new( $condition->{name}, $config );

    my $installed;
    eval {
        my $condition = Blender::Condition->new( %{ $condition } );
        $installed = $target->install_declared( $condition );
    };

    if ( Blender::Error->caught or Blender::Exception->caught ) {
        Blender::Message->notify( $@ );
        say "\nPlease check build logile:" . Blender::Logger->logfile;

        undef $condition;
        return;
    }

    if ( $@ ) {
        die $@;
    }

    undef $condition;

    return unless $installed;
    Blender::ConfigCollector->set( $installed );
}

sub define(&) {
    return $_[0];
}

sub version($) {
    $condition->{version} = $_[0];
}

sub make_test(;$) {
    $condition->{make_test} = $_[0];
}

sub modules($) {
    my $modules = shift;

    if ( ! $modules ) {
        die( "ERROR:condition 'modules' requires module parameter.\n" );
    }

    if ( ref( $modules ) ne 'HASH' ) {
        die( "ERROR:condition 'modules' must set hash reference.\n" );
    }

    $condition->{modules} = $modules;
}

our $setuped;
sub _setup_directory {

    unless ( $setuped ) {
        Blender::Home->create_build_directory;
        Blender::Logger->rotate( Blender::Home->log );

        $setuped++;
    }
}

sub parse_option {

    my $make_test;
    my $force;
    my $deploy_path;

    Getopt::Long::Configure( "bundling" );
    Getopt::Long::GetOptions(
            't|test'        => sub { $make_test = 1 },
            'f|force'       => sub { $force = 1 },
            'd|deploy=s'    => \$deploy_path,
            );

    require Blender::Feature;
    Blender::Feature->initialize(
            make_test   =>  $make_test,
            force       =>  $force,
            deploy      =>  $deploy_path,
            );
}

1;
