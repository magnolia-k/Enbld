# Enbld

*Enbld is yet another package manager for building development environment.*

Enbld helps you install the software required for software development (programming language, text editor, version control system, etc).

- Unlike other package manager, Enbld can install specific version.

- Unlike other programing language version manager, Enbld offers a same interface for all programing language.

- All conditions of installation are defined by using perl-based DSL.

        target 'git' => define {
            version 'latest'; # -> install latest version
        }

        target 'perl' => define {
            version '5.18.1'; # -> install specific version
        }

# SUPPORTED PLATFORMS

*Enbld is performing verification of running on OS X Mavericks.*

But probably, it may run also on Linux (Debian, Ubuntu etc.).

When not running, I'm waiting for the report :)

# REQUIREMENTS

 - perl 5.12 or above

    NOTE:Enbld certainly use the system perl (`/usr/bin/perl`). 

 - make

 - compiler (gcc or clang)

 - other stuff required for individual target software (e.g. JRE for scala etc.)

# INSTALLATION

    $ curl -L http://goo.gl/MrbDDB | perl

To run Enbld, since a set of PATH is required, add to an environment variables according to the message. 

# MORE DOCUMENTS

Displays the fundamental informational of Enbld.

    $ enblder readme

Displays the tutorial of Enbld.

    $ enblder tutorial

# WEB SITE

[https://github.com/magnolia-k/Enbld](https://github.com/magnolia-k/Enbld)

[http://code-stylistics.net/enbld](http://code-stylistics.net/enbld)

# ISSUE REPORT

[https://github.com/magnolia-k/Enbld/issues](https://github.com/magnolia-k/Enbld/issues)

# COPYRIGHT

copyright 2013- Magnolia <magnolia.k@me.com>.

# LICENSE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
