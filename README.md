# NAME

Blender-Declare - Blend your development environment by perl-based DSL.

# SYNOPSIS

    #!/usr/bin/perl

    use 5.012;
    use warnings;

    use utf8;

    use lib "$ENV{HOME}/blended/Blender-Declare/lib/perl5/";

    use Blender::Declare;

    blend 'myblendedenv' => build {

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

Blender-Declare is a tool for building(blending) development environment. 

If installation conditions (a version, the execution of a test code, configuration file etc.) are described to be software to install in perl-based DSL and it executes, download of a source code, building, and installation will be performed altogether automatically. 

If DSL is performed once again when the software of a later more high version is released, the latest version will be installed automatically. 

All the software is installed in a home directory. 

It works on Mac OS X only.

# INSTALLATION

    $ git clone https://github.com/magnolia-k/Blender-Declare.git
    $ cd Blender-Declare
    $ ./setup

And set Blender-Declare's path.

    export $PATH=$HOME/blended/bin:$HOME/blended/Blender-Declare/bin:$PATH
    export MANPATH=$HOME/blended/share/man:$HOME/blended/man:$MANPATH

# GETTING STARTED

## INSTALL LATEST TARGET SOFTWARE

### Ready DSL file.

    $ cat samples/git_install.plx
    #!/usr/bin/perl

    use 5.012;
    use warnings;

    use utf8;

    use lib "$ENV{HOME}/blended/Blender-Declare/lib/perl5/";

    use Blender::Declare;

    blend 'myblendedenv' => build {

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
    
    use lib "$ENV{HOME}/blended/Blender-Declare/lib/perl5/";
    
    use Blender::Declare;
    
    blend 'myblendedenv' => build {
    
        target 'tmux' => define {
            version '1.8';
        };
    
    };

'tmux 1.8' is installed.

    $ tmux -V
    tmux 1.8

## CREATE CONFIGURATION FILE (DOTFILE)

Blender-Declare also can create target software's configuration file(.dotfile).

'conf' function set configuration file to home directory.

    $ cat samples/vim_install.plx
    #!/usr/bin/perl
    
    use 5.012;
    use warnings;
    
    use utf8;
    
    use lib "$ENV{HOME}/blended/Blender-Declare/lib/perl5/";
    
    use Blender::Declare;
    
    blend 'myblendedenv' => build {
    
        target 'vim' => define {
            version 'latest';
        };
    
        conf '.vimrc' => load {
            from 'https://raw.github.com/magnolia-k/vimrc/master/.vimrc';
        };
    
    };

'.vimrc' is downloaded from 'https://raw.github.com/magnolia-k/vimrc/master/.vimrc'.

## MAKE TEST AT INSTALLATION

Blender-Declare can make test at installation.

    target 'git' => define {
        version 'latest';
        make_test 1;
    };

As default, this function is OFF. 

## UTILITY COMMAND 'blender'

Blender-Declare installs utility command 'blender'.

### Displays available software

Subcommand 'available' displays software that can install by Blender-Declare.

    $ blender available

### Displays installed software

Subcommand 'list' displays software that is installed.

    $ blender list

### Displays DSL

Subcommand 'freeze ' displays DSL that is condition of installed software.

    $ blender freeze

# SEE ALSO

- Blender::Declare::Tutorial

# COPYRIGHT

copyright 2013- Magnolia <magnolia.k@me.com>.


# LICENSE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
