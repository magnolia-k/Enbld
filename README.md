# NAME

Enbld - Build your development environment by perl-based DSL.

# SYNOPSIS

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

# DESCRIPTION

**Enbld is a tool for building development environment.**

Write installation conditions (a version - latest or specific version number, the execution of a test code, configuration file etc.) of target software in perl-based DSL,then download of a source code, building, and installation will be performed altogether automatically.

If DSL is performed once again when the software of a later more high version is released, the latest version will be installed automatically.


## FEATURES

- Configuration file which described installation conditions is defined by perl-based DSL. 

    Once it writes a configuration file, same environment is easily reproducible . 

- Arbitrary versions are installable. 

    If it is specified as 'latest', the latest version will be judged automatically and it will be installed. 
The version will be installed if arbitrary versions are specified. 

    Like other package management systems (Homebrew, MacPorts etc.), the package managerial system side does not specify a version. 

- It can be confirmed whether a version higher than the version installed is released. 

    The software (vim, git, etc.) upgraded frequently can also always use the latest version. 


- All software is installed in a home directory.

    Software which became unnecessary can be deleted easily. 

### Supported software

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


## ANTI-FEATURES

- Enbld does NOT aim at perfect package management software. 

  The selection plan of the software to support by Enbld is as follows. 

  - Software required for a developer updated frequently (e.g. git, vim).
  - Software with which the developer who has participated in the project needs to unite a version (e.g. web server, database, programming language etc.).
  - Software required for a developer although not installed in Mac OS X (e.g. tmux).


- It does not have a function which overlaps with the module controlling function which each software has (e.g. CPAN,gem etc.).

## SUPPORTED PLATFORMS

Enbld is performing verification of running on Mac OS X 10.8 Mountain Lion.

Probably, it may operate also on Linux (Debian etc.). 
When not running, it is waiting for the report :)

## CAUTION

**Success of building of all the versions is not guaranteed. Since log file is displayed when building goes wrong, please analyze and send report:)**


# INSTALLATION

- Install by Enbld installer (Download tarball from CPAN).

    $ curl -L http://goo.gl/MrbDDB | perl

or

- Install from tarball.

    Download and unpack tarball (Download tarball from CPAN or GitHub).
    
    $ tar xvf Enbld-x.xxxx.tar.gz
    $ cd Enbld-x.xxxx
    $ ./setup

Enbld installs all the components in a $HOME/.enbld directory.Therefore, it is necessary to set the path of the software which Enbld installed. 

Set Enbld's path.

In .bashrc, write below setting.

    export $PATH=$HOME/.enbld/bin:$HOME/.enbld/extlib/bin:$PATH
    export MANPATH=$HOME/.enbld/share/man:$HOME/.enbld/man:$MANPATH

# GETTING STARTED

## INSTALL LATEST VERSION

### Ready configuration file

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

### Execute configuration file

    $ ./samples/git_install.plx

### Target software is installed

    $ git --version
    git version [latest version]

### Upgrade installed software

Then, if the software of a latest version is released, please execute a configuration file again. 
The software of the latest version will be installed.

    $ ./samples/git_install.plx

Latest software is installed.

## INSTALL SPECIFIC VERSION

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

## DOWNLOAD OR CREATE SOFTWARE' CONFIGURATION FILE (DOTFILE)

Enbld also can create software' configuration file(.dotfile).

'conf' function set software' configuration file to home directory.

### Download software' configuration file


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


### Create software' configuration file

    conf '.vimrc' => set {
        content 'syntax on';
        content 'set cindent';
    };

'.vimrc' is created to $HOME.

Nothing is done when the file of the same file name already exists. 


## MAKE TEST AT INSTALLATION

Enbld can make test at installation.

    target 'git' => define {
        version 'latest';
        make_test 1;
    };

As default, this function is OFF. 

If a test goes wrong, also building will go wrong. 


## ADD ARGUMENTS

'arguments' method adds additional arguments to './configure'.

    target 'perl' => define {
        version '5.18.1';
        arguments '-Dusethreads';
    };

perl 5.18.1 with thread

    $ perl -v
    
    This is perl 5, version 18, subversion 1 (v5.18.1) built for darwin-thread-multi-2level

## UTILITY COMMAND 'enblder'

Enbld installs utility command 'enblder'.

### Displays available software

Subcommand 'available' displays software that can install by Enbld.

    $ enblder available


### Displays installed software

Subcommand 'list' displays software that is installed.

    $ enblder list

### Displays configuration file

Subcommand 'freeze' displays configuration file that is condition of installed software.

    $ enblder freeze

### Displays outdated software

Subcommand 'outdated' displays outdated software list.

    $ enblder outdated

### Upgrade outdated software

Subcommand 'upgrade' upgrade outdated software.

    $ enblder upgrade git

# SEE ALSO

- lib/Enbld::Tutorial
- bin/enblder

# COPYRIGHT

copyright 2013- Magnolia <magnolia.k@me.com>.


# LICENSE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
