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

    PREREQ_PM		=> {
    },

	META_MERGE		=> {
		"no_index" => {
			"directory" => [ "xt" ]
	    },
	},

    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Enbld-*' },
);
