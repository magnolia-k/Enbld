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

Enbld is a tool for building development environment. 

If installation conditions (a version, the execution of a test code, configuration file etc.) are described to be software to install in perl-based DSL and it executes, download of a source code, building, and installation will be performed altogether automatically. 

If DSL is performed once again when the software of a later more high version is released, the latest version will be installed automatically. 

All the software is installed in a home directory. 

Enbld is performing verification of operation by Mac OS X 10.8 Mountain Lion.

However, probably I also regard Linux as operating (Debian etc.). 
When not operating, it is waiting for the report :)


# INSTALLATION

    $ git clone https://github.com/magnolia-k/Enbld.git
    $ cd Enbld
    $ ./setup

And set Enbld's path.

    export $PATH=$HOME/.enbld/bin:$HOME/.enbld/extlib/bin:$PATH
    export MANPATH=$HOME/.enbld/share/man:$HOME/.enbld/man:$MANPATH

# GETTING STARTED

## INSTALL LATEST TARGET SOFTWARE

### Ready DSL file.

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

### Execute DSL file.

    $ ./samples/git_install.plx

### Target software is installed.

    $ git --version
    git version [latest version]

### Upgrade target software

Then, if the software of a latest version is released, please execute a DSL file again. 
The software of the latest version will be installed.

    $ ./samples/git_install.plx

Latest software is installed.

## INSTALL SPECIFIC VERSION SOFTWARE

A specific version is specified in DSL. -> version '1.8';

    $ cat samples/specific_version_install.plx
    #!/usr/bin/perl
    
    use 5.012;
    use warnings;
    
    use utf8;
    
    use lib "$ENV{HOME}/.enbld/extlib/lib/perl5/";
    
    use Enbld;
    
    enbld 'myenv' => build {
    
        target 'tmux' => define {
            version '1.8';
        };
    
    };

'tmux 1.8' is installed.

    $ tmux -V
    tmux 1.8

## CREATE CONFIGURATION FILE (DOTFILE)

Enbld also can create target software's configuration file(.dotfile).

'conf' function set configuration file to home directory.

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

'.vimrc' is downloaded from 'https://raw.github.com/magnolia-k/vimrc/master/.vimrc'.

## MAKE TEST AT INSTALLATION

Enbld can make test at installation.

    target 'git' => define {
        version 'latest';
        make_test 1;
    };

As default, this function is OFF. 

## UTILITY COMMAND 'enbld'

Enbld installs utility command 'enbld'.

### Displays available software

Subcommand 'available' displays software that can install by Enbld.

    $ enbld available

### Displays installed software

Subcommand 'list' displays software that is installed.

    $ enbld list

### Displays DSL

Subcommand 'freeze ' displays DSL that is condition of installed software.

    $ enbld	freeze

# SEE ALSO

- Enbld::Tutorial

# COPYRIGHT

copyright 2013- Magnolia <magnolia.k@me.com>.


# LICENSE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
