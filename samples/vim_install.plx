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

