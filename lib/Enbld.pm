package Enbld;

use 5.012;
use warnings;

use FindBin qw/$Script/;
use Getopt::Long;

our $VERSION = '0.7016';

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
                "INFO:Enbld is set 'deploy mode'.\n" .
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

=pod

=head1 NAME

Enbld - Build your development environment by perl-based DSL.

=head1 SYNOPSIS

 #!/usr/bin/perl

 use 5.012;
 use warnings;

 use utf8;

 use lib "$ENV{HOME}/.enbld/extlib/lib/perl5/";

 use Enbld;

 enbld 'myenv' => build {

     # install latest version
     target 'git' => define {
         version 'latest';
     };

     # install specific version
     target 'tmux' => define {
         version '1.8';
     };

     # install software and set configuration file
     target 'vim' => define {
         version 'latest';
     };

     conf '.vimrc' => load {
         from 'https://raw.github.com/magnolia-k/vimrc/master/.vimrc';
     };
 };

=head1 DESCRIPTION

B<Enbld is a tool for building development environment.>

Write installation conditions (a version - latest or specific version number, the execution of a test code, configuration file etc.) of target software in perl-based DSL,then download of a source code, building, and installation will be performed altogether automatically.

If DSL is performed once again when the software of a later more high version is released, the latest version will be installed automatically.


=head2 FEATURES

=over 3

=item * Configuration file which described installation conditions is defined by perl-based DSL. 

Once it writes a configuration file, same environment is easily reproducible . 

=item * Arbitrary versions are installable. 

If it is specified as 'latest', the latest version will be judged automatically and it will be installed. 

=item * The version will be installed if arbitrary versions are specified. 

Like other package management systems (Homebrew, MacPorts etc.), the package managerial system side does not specify a version. 

=item * It can be confirmed whether a version higher than the version installed is released. 

The software (vim, git, etc.) upgraded frequently can also always use the latest version. 

=item * All software is installed in a home directory.

Software which became unnecessary can be deleted easily. 

=back

=head3 Supported software

Now, Enbld supports for installation below software.

 apache         http://httpd.apache.org
 apr            http://apr.apache.org
 aprutil        http://apr.apache.org
 autoconf       http://www.gnu.org/software/autoconf/
 automake       http://www.gnu.org/software/automake/
 cmake          http://www.cmake.org
 emacs          http://www.gnu.org/software/emacs/
 git            http://git-scm.com
 groff          http://www.gnu.org/software/groff/
 hello          http://www.gnu.org/software/hello/
 libevent       http://libevent.org
 libidn         http://www.gnu.org/software/libidn/
 libtool        http://www.gnu.org/software/libtool/
 mysql          http://www.mysql.com
 nginx          http://nginx.org
 nodejs         http://nodejs.org
 pcre           http://www.pcre.org
 perl           http://www.perl.org
 pkgconfig      http://www.freedesktop.org/wiki/Software/pkg-config/
 python         http://www.python.org
 rakudostar     http://rakudo.org
 ruby           https://www.ruby-lang.org
 scala          http://www.cmake.org
 tmux           http://tmux.sourceforge.net
 tree           http://mama.indstate.edu/users/ice/tree/
 vim            http://www.vim.org
 wget           http://www.gnu.org/software/wget/
 zsh            http://www.zsh.org


=head2 ANTI-FEATURES

=over 3

=item * Enbld does NOT aim at perfect package management software. 

The selection plan of the software to support by Enbld is as follows. 

=over 3

=item * Software required for a developer updated frequently (e.g. git, vim).

=item * Software with which the developer who has participated in the project needs to unite a version (e.g. web server, database, programming language etc.).

=item * Software required for a developer although not installed in Mac OS X (e.g. tmux).

=back

=item * It does not have a function which overlaps with the module controlling function which each software has (e.g. CPAN,gem etc.).

=back

=head2 SUPPORTED PLATFORMS

B<Enbld is performing verification of running on Mac OS X 10.8 Mountain Lion.>

Probably, it may operate also on Linux (Debian etc.). 
When not running, it is waiting for the report :)

=head2 CAUTION

B<Success of building of all the versions is not guaranteed. Since log file is displayed when building goes wrong, please analyze and send report:)>


=head1 INSTALLATION

Install by Enbld installer (Download tarball from CPAN).

 $ curl -L http://goo.gl/MrbDDB | perl

or

Install from tarball.

 Download and unpack tarball (Download tarball from CPAN or GitHub).

 $ tar xvf Enbld-x.xxxx.tar.gz
 $ cd Enbld-x.xxxx
 $ ./setup

Enbld installs all the components in a $HOME/.enbld directory.Therefore, it is necessary to set the path of the software which Enbld installed. 

Set Enbld's path.

In .bashrc, write below setting.

 export $PATH=$HOME/.enbld/bin:$HOME/.enbld/extlib/bin:$PATH
 export MANPATH=$HOME/.enbld/share/man:$HOME/.enbld/man:$MANPATH

=head1 GETTING STARTED

=head2 INSTALL LATEST VERSION

=head3 Ready configuration file

 $ cat samples/git_install.plx
 #!/usr/bin/perl

 use 5.012;
 use warnings;

 use utf8;

 use lib "$ENV{HOME}/.enbld/extlib/lib/perl5/";

 use Enbld;

 enbld 'myenv' => build {

     target 'git' => define {
         version 'latest';
     };
 }

=head3 Execute configuration file

 $ ./samples/git_install.plx

=head3 Target software is installed

 $ git --version
 git version [latest version]

=head3 Upgrade installed software

Then, if the software of a latest version is released, please execute a configuration file again. 
The software of the latest version will be installed.

 $ ./samples/git_install.plx

Latest software is installed.

=head2 INSTALL SPECIFIC VERSION

A specific version is specified in setting file. -> version '5.18.1';

 $ cat samples/specific_version_install.plx
 #!/usr/bin/perl
    
 use 5.012;
 use warnings;
    
 use utf8;
    
 use lib "$ENV{HOME}/.enbld/extlib/lib/perl5/";
    
 use Enbld;
    
 enbld 'myenv' => build {
    
     target 'perl' => define {
         version '5.18.1';
     };
    
 };

'perl 5.18.1' is installed.

 $ perl -v

 This is perl 5, version 18, subversion 1 (v5.18.1) built for darwin-multi-2level

=head2 DOWNLOAD OR CREATE SOFTWARE' CONFIGURATION FILE (DOTFILE)

Enbld also can create software' configuration file(.dotfile).

'conf' function set software' configuration file to home directory.

=head3 Download software' configuration file

 $ cat samples/vim_install.plx
 #!/usr/bin/perl
    
 use 5.012;
 use warnings;
    
 use utf8;
    
 use lib "$ENV{HOME}/.enbld/extlib/lib/perl5/";
    
 use Enbld;
    
 enbld 'myenv' => build {
    
     target 'vim' => define {
         version 'latest';
     };
    
     conf '.vimrc' => load {
         from 'https://raw.github.com/magnolia-k/vimrc/master/.vimrc';
     };
    
 };

'.vimrc' is downloaded to $HOME from 'https://raw.github.com/magnolia-k/vimrc/master/.vimrc'.

Nothing is done when the file of the same file name already exists. 


=head3 Create software' configuration file

 conf '.vimrc' => set {
     content 'syntax on';
     content 'set cindent';
 };

'.vimrc' is created to $HOME.

Nothing is done when the file of the same file name already exists. 


=head2 MAKE TEST AT INSTALLATION

Enbld can make test at installation.

 target 'git' => define {
     version 'latest';
     make_test 1;
 };

As default, this function is OFF. 

If a test goes wrong, also building will go wrong. 


=head2 ADD ARGUMENTS

'arguments' method adds additional arguments to './configure'.

 target 'perl' => define {
     version '5.18.1';
     arguments '-Dusethreads';
 };

perl 5.18.1 with thread

 $ perl -v
    
 This is perl 5, version 18, subversion 1 (v5.18.1) built for darwin-thread-multi-2level

=head2 UTILITY COMMAND 'enblder'

Enbld installs utility command 'enblder'.

=head3 Displays available software

Subcommand 'available' displays software that can install by Enbld.

 $ enblder available


=head3 Displays installed software

Subcommand 'list' displays software that is installed.

 $ enblder list

=head3 Displays configuration file

Subcommand 'freeze' displays configuration file that is condition of installed software.

 $ enblder freeze

=head3 Displays outdated software

Subcommand 'outdated' displays outdated software list.

 $ enblder outdated

=head3 Upgrade outdated software

Subcommand 'upgrade' upgrade outdated software.

 $ enblder upgrade git

=head1 SEE ALSO

L<Enbld::Tutorial>

L<enblder>

=head1 COPYRIGHT

copyright 2013- Magnolia C<< <magnolia.k@me.com> >>.

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

