package Enbld;

use 5.012;
use warnings;

use FindBin qw/$Script/;
use Getopt::Long;

our $VERSION = '0.7002';

require Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw/
    enbld
    build
    target
    define
    version
    make_test
    modules
    arguments
    annotation
    conf
    load
    set
    from
    to
    content
/;

use Enbld::Catchme;

require Enbld::App::Configuration;
require Enbld::Logger;
require Enbld::Target;
require Enbld::Condition;
require Enbld::Error;
require Enbld::Exception;
require Enbld::RcFile;
require Enbld::Deployed;

our $initialized;
our %target_result;
our %rcfile_result;

our %rcfile_collection;
our %target_collection;

sub enbld($$) {
    my ( $envname, $coderef ) = @_;

    if ( ref( $envname ) ) {
        _err(
                "Function 'enbld' first requires " .
                "string type parameter 'env name'."
                );
    }

    if ( $envname =~ /[^0-9a-zA-Z_]/ ) {
        _err(
                "Env name '$envname' contains invalid character.",
                $envname
                );
    }

    if ( ref( $coderef ) ne 'CODE' ) {
        _err( "Function 'enbld' second requires code reference parameter." );
    }

    require Enbld::Message;
    Enbld::Message->set_verbose;

    parse_option();

    require Enbld::Home;
    Enbld::Home->initialize;

    Enbld::App::Configuration->read_file;
    Enbld::App::Configuration->set_envname( $_[0] );

    $initialized++;

    $_[1]->();

    Enbld->_setup_directory;

    foreach my $name ( sort keys %target_collection ) {
        build_target( $name );
    }

    foreach my $filepath ( sort keys %rcfile_collection ) {
        load_or_set_rcfile( $rcfile_collection{$filepath} );
    }

    undef $initialized;

    show_result_message();

    check_targets_in_DSL();

    if ( ! Enbld::App::Configuration->is_dirty ) {
        Enbld::Message->notify(
                "INFO:No builded targets & loaded configuration file."
                );
    }

    return 1;
}

sub build_target {
    my $name = shift;

    my $config = Enbld::Feature->is_deploy_mode ? undef :
        Enbld::App::Configuration->search_config( $name );

    my $target = Enbld::Target->new( $name, $config );

    my $installed;
    eval {
        if ( Enbld::Feature->is_deploy_mode ) {
            $installed = $target->deploy_declared( \%target_collection );
        } else {
            $installed = $target->install_declared( \%target_collection );
        }
    };

	catchme 'Enbld::Error' => sub {
        Enbld::Message->alert( $@ );

        print "\n";
        print "Please check build logile:" . Enbld::Logger->logfile . "\n";

        $target_result{$name} = $name . ' is failure to build.';

        return;
    };

    # Target is installed.
    if ( $installed ) {
        $target_result{$name} = $name . ' ' . $installed->enabled .
            " is installed.";

        Enbld::App::Configuration->set_config( $installed );
        Enbld::App::Configuration->write_file;

        if ( Enbld::Feature->is_deploy_mode ) {
            Enbld::Deployed->add( $installed );
        }

        return $name;
    }

    # Target is up-to-date.
    $target_result{$name} = $name . ' is up-to-date.';

    return $name;
}

sub check_targets_in_DSL {

    return if Enbld::Feature->is_deploy_mode;

    my %not_in_dsl;
    foreach my $name ( keys %{ Enbld::App::Configuration->config } ) {
        my $config = Enbld::App::Configuration->search_config( $name );

        $not_in_dsl{$name}++ unless defined $target_result{$name};
    }

    if ( keys %not_in_dsl ) {
        Enbld::Message->notify(
                "WARN:The following targets are not defined in DSL $Script.\n" .
                "Please check $Script."
                );

        foreach my $target ( sort keys %not_in_dsl ) {
            Enbld::Message->notify( "    " . $target );
        }
    }
}

sub show_result_message {

    foreach my $target ( sort keys %target_result ) {
        Enbld::Message->notify( $target_result{$target} );
    }

    foreach my $file ( sort keys %rcfile_result ) {
        Enbld::Message->notify( $rcfile_result{$file} );
    }
}

sub build(&) {
    return $_[0];
}

our $condition_ref;

sub target($$) {
    my ( $targetname, $coderef ) = @_;

    if ( ! $initialized ) {
        _err(
                "Environment is not initialized.".
                "Isn't the syntax of DSL possibly mistaken?"
                );
    }

    if ( ref( $targetname ) ) {
        _err(
                "Function 'target' first requsres " .
                "string type parameter 'target name'."
                );
    }

    if( $targetname =~ /[^0-9a-z]/ ) {
        _err( "Target name '$targetname' contains invalid character." );
    }

    if ( ref( $coderef ) ne 'CODE' ) {
        _err( "Function 'target' seconde requires code reference parameter." );
    }

    $condition_ref = {
        name        =>  $targetname,
    };

    $coderef->();

    my $condition = Enbld::Condition->new( %{ $condition_ref } );
    $target_collection{$targetname} = $condition;

    undef $condition_ref;
}

sub define(&) {
    my $coderef = shift;

    return $coderef;
}

sub version($) {
    my $version = shift;

    if ( ref( $version ) ) {
        _err( "Function 'version' requires string type parameter." );
    }

    $condition_ref->{version} = $version;
}

sub make_test(;$) {
    my $make_test = shift;

    if ( $make_test && ref( $make_test ) ) {
        _err( "Function 'make_test' requires string type parameter." );
    }

    $condition_ref->{make_test} = $make_test if $make_test;
}

sub arguments($) {
    my $arguments = shift;

    if ( ref( $arguments ) ) {
        _err( "Function 'arguments' requires string type parameter." );
    }

    $condition_ref->{arguments} = $arguments;
}

sub annotation($) {
    my $annotation = shift;

    if ( ref( $annotation ) ) {
        _err( "Function 'annotation' requires string type parameter." );
    }

    $condition_ref->{annotation} = $annotation;
}

sub modules($) {
    my $modules = shift;

    if ( ref( $modules ) ne 'HASH' ) {
        _err( "Function 'modules' requires HASH reference type parameter." );
    }

    $condition_ref->{modules} = $modules;
}

our $rcfile_condition;
sub conf($$) {
    my ( $filepath, $coderef ) = @_;    

    if ( ! $initialized ) {
        _err(
                "Environment is not initialized.".
                "Isn't the syntax of DSL possibly mistaken?"
                );
    }

    if ( ref( $filepath ) ) {
        _err( "Function 'conf' first requires string type parameter." );
    }

    if ( $filepath =~ /\s/ ) {
        _err(
                "Configuration file path parameter must " .
                "not contain space character."
                );
    }

    if ( ref( $coderef ) ne 'CODE' ) {
        _err( "Function 'conf' requires code reference type parameter." );
    }

    $coderef->();

    $rcfile_condition->{filepath} = $filepath;
    $rcfile_collection{$filepath} = Enbld::RcFile->new( %{ $rcfile_condition } );

    undef $rcfile_condition;
}

sub load_or_set_rcfile {
    my $rcfile = shift;

    my $result;
    eval {
        $result = $rcfile->do;
    };

    # Catch exception.
	catchme 'Enbld::Error' => sub {
        Enbld::Message->alert( $@ );

        print "\n";
        print "Please check build logile:" . Enbld::Logger->logfile . "\n";

        $rcfile_result{$rcfile->filepath} =
            $rcfile->filepath . ' is failure to load or set.';

        return;
    };

    # Configuration file is loaded or set.
    if ( $result ) {

        Enbld::App::Configuration->set_rcfile( $rcfile );
        Enbld::App::Configuration->write_file;

        $rcfile_result{$rcfile->filepath} =
            $rcfile->filepath . ' is loaded or set.';

        return $result;
    }

    # Configuration file is not loaded or set.
    $rcfile_result{$rcfile->filepath} =
        $rcfile->filepath . ' is not loaded or set.';

    return;
}

sub load(&) {
    $rcfile_condition->{command} = 'load';

    return $_[0];
}

sub set(&) {
    $rcfile_condition->{command} = 'set';

    return $_[0];
}

sub from($) {
    my $url = shift;

    if ( ref( $url ) ) {
        _err( "Function 'from' requsres string type parameter." );
    }

    my $pattern = q{s?https?://[-_.!~*'()a-zA-Z0-9;/?:@&=+$,%#]+};

    if ( $url !~ /$pattern/ ) {
        _err( "Function 'from' requires valid URL parameter.", $url );
    }

    $rcfile_condition->{url} = $url;
}

sub to($) {
    my $to = shift;

    if ( ref( $to ) ) {
        _err( "Function 'to' requsres string type parameter." );
    }

    if ( $rcfile_condition->{directory} =~ /\s/ ) {
        _err( "Function 'to' must not contain space character." );
    }

    $rcfile_condition->{directory} = shift;
}

sub content($) {
    my $content = shift;

    if ( ref( $content ) ) {
        _err( "Function 'content' reuqires string type parameter." );
    }

    chomp( $content );

    $rcfile_condition->{contents} .= $content . "\n";
}

our $setuped;
sub _setup_directory {

    unless ( $setuped ) {
        Enbld::Home->create_build_directory;
        Enbld::Logger->rotate( Enbld::Home->log );

        $setuped++;
    }
}

sub parse_option {

    my $make_test;
    my $force;
    my $deploy_path;

    Getopt::Long::Configure( "bundling" );
    Getopt::Long::GetOptions(
            't|test'        => sub { $make_test++ },
            'f|force'       => sub { $force++ },
            'd|deploy=s'    => \$deploy_path,
            );

    require Enbld::Feature;
    Enbld::Feature->initialize(
            make_test   =>  $make_test,
            force       =>  $force,
            deploy      =>  $deploy_path,
            );

    if ( Enbld::Feature->is_deploy_mode ) {
        Enbld::Message->notify(
                "INFO:Enbld::Declare is set 'deploy mode'.\n" .
                "All targets will be deployed in $deploy_path."
                );
    }

    if ( Enbld::Feature->is_make_test_all ) {
        Enbld::Message->notify(
                "INFO:Enbld::Declare is set 'make test mode'.\n" .
                "All targets will be tested."
                );
    }

    if ( Enbld::Feature->is_force_install ) {
        Enbld::Message->notify(
                "INFO:Enbld::Declare is set 'force install mode'.\n" .
                "All targets will be builded by force."
                );
    }

}

sub _err {
    my ( $msg, $param ) = @_;

    die( Enbld::Error->new( $msg, $param ) );
}

1;
