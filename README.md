# NAME

Blender-Declare - Blend your development environment in your home directory.

# SYNOPSIS

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
    };

# DESCRIPTION

Blender-Declare is a tool for building(blending) development environment. 

If installation conditions (a version, the execution existence of a test code, etc.) are described to be software to install in DSL and it executes, download of a source code, building, and installation will be performed altogether automatically. 

If DSL is performed once again when the software of a later more high version is released, the latest version will be installed automatically. 

All the software is installed in a home directory. 

It works on Mac OS X only.

# INSTALLATION

    git clone https://github.com/magnolia-k/Blender-Declare.git
    cd Blender-Declare
    ./setup

Set Blender-Declare's path.

    export $PATH=$HOME/blended/bin:$HOME/blended/Blender-Declare/bin:$PATH
    export MANPATH=$HOME/share/man:$MANPATH

# GETTING STARTED

Ready DSL file.

    $ cat samples/git_install.plx
    #!/usr/bin/perl

    use 5.012;
    use warnings;

    use lib "$ENV{HOME}/blended/Blender-Declare/lib/perl5/";

    use Blender::Declare;

    blend 'myblendedenv' => build {

        target 'git' => define {
            version 'latest';
        };
    }

Execute DSL file.

    $ ./samples/git_install.plx

Target software is installed.

    $ git --version
    git version [latest version]

Then, if the software of a latest version is released, please execute a DSL file again. 
The software of the latest version will be installed.

    $ ./samples/git_install.plx

Latest software is installed.


# SEE ALSO

- Blender::Declare::Tutorial

# COPYRIGHT

copyright 2013- Magnolia <magnolia.k@me.com>.


# LICENSE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
