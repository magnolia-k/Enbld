#!/usr/bin/perl

use 5.012;
use warnings;

use lib "$ENV{HOME}/.enbld/extlib/lib/perl5/";

use Enbld;

enbld 'myenv' => build {

    target 'autoconf' => define {
        version 'latest';
    };

    target 'automake' => define {
        version 'latest';
    };

    target 'git' => define {
        version 'latest';
    };

    target 'libevent' => define {
        version 'latest';
    };

    target 'perl' => define {
        version 'latest';
        modules {
            'App::cpanminus' => 0,
            'Devel::Cover' => 0,
        };
    };

    target 'pkgconfig' => define {
        version 'latest';
    };

    target 'tmux' => define {
        version 'latest';
    };

    target 'vim' => define {
        version 'latest';
    };

    conf '.vimrc' => load {
        from 'https://raw.github.com/magnolia-k/vimrc/master/.vimrc';
    };

};
