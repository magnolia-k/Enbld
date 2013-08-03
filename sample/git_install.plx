#!/usr/bin/perl

use 5.012;
use warnings;

use lib "$ENV{HOME}/blended/Blender-Declare/lib/perl5/";

use Blender::Declare;

blend 'myblendedenv' => build {

    target 'git' => define {
        version 'latest';
    };

};

