package Enbld::Tutorial;

use strict;
use warnings;

1;

__END__

=pod

=head1 NAME

Enbld::Tutorial - Tutorial for Enbld.

=head1 DESCRIPTION

Enbld::Tutorial is detailed explanation for Enbld.

=head1 INSTALLATION

To install Enbld, use Enbld installer.

 $ curl -L http://goo.gl/MrbDDB | perl

'http://goo.gl/MrbDDB' is shortener link to below URI.

L<https://raw.github.com/magnolia-k/EnbldInstaller/master/bin/enbld_installer>

Installer download tarball from CPAN, and unpack, install automatically.

or

To install, use 'setup' command.

 Download and unpack tarball.
 
 $ tar xvf Enbld-x.xxxx.tar.gz
 $ cd Enbld-x.xxxx
 $ ./setup

Enbld installs all the components in a $HOME/.enbld directory.Therefore, it is necessary to set the path of the software which Enbld installed. 

Add below to .bashrc.

 export $PATH=$HOME/.enbld/bin:$HOME/.enbld/sbin:$HOME/.enbld/extlib/bin:$PATH
 export MANPATH=$HOME/.enbld/share/man:$HOME/.enbld/man:$MANPATH

=head2 Caution at installation

Since you can build perl using Enbld, please be sure to install in a $HOME/.enbld directory using a 'setup' command.

If perl is built using Enbld, it will become impossible to be arranged at the same place as other modules, if it installs using cpan client (e.g. cpanm), but to refer to the module. 

=head1 '.enbld' DIRECTORY COMPOSITION

'.enbld' directory has the following composition. 

 $HOME/.enbld --+
                |
                +-- bin/         executable commands (symbolic links)
                |
                +-- lib/         library files       (symbolic links)
                |
                +-- include/     include files       (symbolic links)
                |
                +-- man/         man files           (symbolic links)
                |
                +-- share/       shared filed        (symbolic links)
                |
                +-- extlib/      Enbld's module files (e.g. lib/Enbld.pm)
                |
                +-- dists/       downloaded software' archivefiles
                |
                +-- etc/         other various files
                |
                +-- build/       software' build directory
                |
                +-- depository/  installed software' compornents files
                |   |
                |   +-- Software A
                |   |   |
                |   |   +-- version 1
                |   |   |
                |   |   +-- version 2
                |   |   |
                |   |
                |   +-- Software B
                |   |   |
                |   |   +-- version 1
                |   |   |
                |
                +--conf/         Enbld's configuration file
                |
                +--log/          Enbld's log files


Enbld installs software to $HOME/depository/[Software Name]/[Version]/ and creates symbolic links to $HOME/bin,$HOME/lib, and so on. Therefore, it can change now easily a newer version. 

=head1 TUTORIAL FOR DSL

=head2 Install latest version

Ready sample configuration file.

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

 };

 $ ./sample/git_install.plx
 =====> Start building target 'git'.

 ...

 =====> Finish building target 'git'.
 git 1.8.4.1 is installed.
 $ git --version
 git version 1.8.4.1

* git of the latest version in October 10, 2013 time is git 1.8.4.1. 

=head2 Install specific version

Rewrite the arguments of 'version' function from 'latest' to '1.8.4'. 

 $ cat samples/git_install.plx
 #!/usr/bin/perl

 use 5.012;
 use warnings;

 use utf8;

 use lib "$ENV{HOME}/.enbld/extlib/lib/perl5/";

 use Enbld;

 enbld 'myenv' => build {

     target 'git' => define {
         version '1.8.4';
     };

 };

 $ ./sample/git_install.plx
 =====> Start building target 'git'.

 ...

 =====> Finish building target 'git'.
 git 1.8.4 is installed.
 $ git --version
 git version 1.8.4


=head2 Upgrade installed software

Re-rewrite the arguments of 'version' function from '1.8.4' to 'latest'. 

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

 };

 $ ./sample/git_install.plx
 =====> Start building target 'git'.

 ...

 =====> Finish building target 'git'.
 git 1.8.4.1 is installed.
 $ git --version
 git version 1.8.4.1

Since git 1.8.4 was not the latest version, 1.8.4.1 of the latest version was installed. 

=head2 How to write configuration file by DSL

=head3 header code

A configuration file certainly begins from the following code. 

 #!/usr/bin/perl

 use 5.012;
 use warnings;

 use lib "$ENV{HOME}/.enbld/extlib/lib/perl5/";

Since system perl is certainly used for Enbld, it sets the path to system perl to shebang. 

Since Enbld is supporting only 5.12 or more perl, it sets 'use 5.012;'.And warnings pragama is used for safety. 

Since the Enbld's modules are stored in '$HOME/.enbld/extlib/perl5/lib', it is added to a reference place by lib pragma. 

=head3 enbld, build

'myenv' is an nvironment name. An environment name can be attached freely. 

 enbld 'myenv' => build {
     ....
 };

=head3 target, define

'target' function defines target software' building condition.

 target 'git => define {
     ....
 };

=head3 version

'version' function takes arbitrary version numbers or 'latest' string. 

 target 'git' => define {
     version 'latest';
 };

 target 'git' => define {
     version '1.8.4';
 };

=head4 development

A part of software (the present condition -- perl only) can specify 'development' as an argument.  Specification of 'development' will install the latest version among development versions. 

 target 'perl' => define {
     version 'development'; # -> installs 5.19.4 at 10/10/2013.
 };

 target 'perl' => define {
     version 'latest';      # -> installs 5.18.1 at 10/10/2013.
 };

=head3 make_test

Pecification of the value (getting it blocked except undef, 0, and null string) judged by the argument of make_test by perl to be truth will perform a test at the time of building. 

 target 'perl' => define {
	 version   'latest';
	 make_test '1';
 };

=head3 arguments

An arguments function is used when specifying an additional arguments as 'configure'. 

 target 'perl' => define {
     version   'latest';
	 arguments '-Dusethreads';
 };

=head3 modules

The specified module can be installed when software is equipped with the module controlling function. 

However, it is support of only perl now. 

 target 'perl' => define {
     version 'latest';

	 modules => {
         'App::cpanminus' => 0,
	 };
 };

=head3 annotation

'annotation' is the notes to the condition. 

Although it is the same as writing a comment using the grammar of perl, even if it uses the freeze subcommand, it differs in that it is displayed perfectly. 

 target 'perl' => define {
     version    'latest';
	 arguments  '-Dusethreads';
     annotation 'use thread veriosn';
 };

=head2 Deploy

A configuration file can take '--deploy' argument.If '--deploy' argument is specified, deploys all software defined by configuration file to specific path.
 
 $ ./sample/git_install.plx --deploy /path/to/install

=head2 Make test

A configuration file can take '--make_test' argument. If '--make_test' argument is specified, make test all software at installation.

 $ ./sample/git_install.plx --make_test

=head1 Enbld's work-flow

 $ ./myenv_install.plx             # install software
 $ enblder list                      # check installed
 $ enblder outdated                  # check outdated
 $ enblder upgrade target_software   # upgrade separately
 $ enblder deploy /path/to/install   # When fully testing, it is deploy. 

=head1 SEE ALSO

L<Enbld>
L<enblder>

=head1 COPYRIGHT

copyright 2013- Magnolia C<< <magnolia.k@me.com> >>.


=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

1;
