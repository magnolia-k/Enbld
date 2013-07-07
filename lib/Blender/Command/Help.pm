package Blender::Command::Help;

use 5.012;
use warnings;

use parent qw/Blender::Command/;

sub do {
    my $help = do { local $/; <DATA> };

    print $help . "\n";

    return $_[0];
}

1;

__DATA__
Usage: blender command target [option]

Commands:
  install   Install target.
  outdated  Display outdated targets.
  upgrade   Install target for newer version.
  search    Display targets for supported by blender.
  list      Display installed targets with current version.
  freeze    Display DSL that now installed targets' condition.
  available Display available definitions.
  deploy    Install all targets in the specified directory.

Options:
  -h,--help     Displays blender's help.
  -v,--version  Displays blender's version.
  -f,--force    Install target whether it is installed or not.
  -n,--notest   Skip target's test at installtion process. - now default
  -t,--test     Execute target's test at installtion process.
  -c,--curret   Displays target's current installed version at 'freeze' command.
