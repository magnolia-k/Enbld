use 5.006;

use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Enbld',
    AUTHOR           => q{magnolia <magnolia.k@me.com>},
    VERSION_FROM     => 'lib/Enbld.pm',
    ABSTRACT_FROM    => 'lib/Enbld.pm',
    LICENSE          => 'perl',
    MIN_PERL_VERSION => 5.012,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 6.56,
    },

    "EXE_FILES" => [
        "bin/enblder",
        "bin/chkenbld",
        "bin/getenbld",
    ],

    PREREQ_PM		=> {
    },

	META_MERGE		=> {
        "meta-spec" => { version => 2 },

		"no_index" => {
			"directory" => [ "xt" ]
	    },

        "resources" => {
            "homepage" => "https://github.com/magnolia-k/Enbld",

            "bugtracker" => {
                "web" => "https://github.com/magnolia-k/Enbld/issues",
            },

            "repository" => {
                "type" => "git",
                "url"  => "https://github.com/magnolia-k/Enbld.git",
                "web"  => "https://github.com/magnolia-k/Enbld",
            },
        },
	},

    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Enbld-*' },
);
