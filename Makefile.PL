use 5.006;

use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile1(
    #CONFIGURE_REQUIRES => {
    #},
    #BUILD_REQUIRES => {
    #},

    NAME             => 'Enbld',
    AUTHOR           => q{magnolia <magnolia.k@me.com>},
    VERSION_FROM     => 'lib/Enbld.pm',
    ABSTRACT_FROM    => 'lib/Enbld.pm',
    LICENSE          => 'perl',
    MIN_PERL_VERSION => 5.010001,

    TEST_REQUIRES => {
        'Test::More'        => 0.98,
        'Test::Output'      => 0,
        'Test::Exception'   => 0,
    },

    "EXE_FILES" => [
        "bin/enblder",
        "bin/chkenbld",
        "bin/getenbld",
    ],

    PREREQ_PM		=> {
        'version'               => 0.77,
        'autodie'               => 0,
        'parent'                => 0,
        'LWP'                   => 0,
        'LWP::Protocol::https'  => 0,
        'Mozilla::CA'           => 0,
        'Try::Lite'             => 0,
        'File::Copy::Recursive' => 0,
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

sub WriteMakefile1 {  #Compatibility code for old versions of EU::MM. Written by Alexandr Ciornii, version 0.23. Added by eumm-upgrade.
    my %params=@_;
    my $eumm_version=$ExtUtils::MakeMaker::VERSION;
    $eumm_version=eval $eumm_version;
    die "EXTRA_META is deprecated" if exists $params{EXTRA_META};
    die "License not specified" if not exists $params{LICENSE};
    if ($params{AUTHOR} and ref($params{AUTHOR}) eq 'ARRAY' and $eumm_version < 6.5705) {
        $params{META_ADD}->{author}=$params{AUTHOR};
        $params{AUTHOR}=join(', ',@{$params{AUTHOR}});
    }
    if ($params{TEST_REQUIRES} and $eumm_version < 6.64) {
        $params{BUILD_REQUIRES}={ %{$params{BUILD_REQUIRES} || {}},
            %{$params{TEST_REQUIRES}} };
        delete $params{TEST_REQUIRES};
    }
    if ($params{BUILD_REQUIRES} and $eumm_version < 6.5503) {
        #EUMM 6.5502 has problems with BUILD_REQUIRES
        $params{PREREQ_PM}={ %{$params{PREREQ_PM} || {}} , %{$params{BUILD_REQUIRES}} };
        delete $params{BUILD_REQUIRES};
    }
    delete $params{CONFIGURE_REQUIRES} if $eumm_version < 6.52;
    delete $params{MIN_PERL_VERSION} if $eumm_version < 6.48;
    delete $params{META_MERGE} if $eumm_version < 6.46;
    delete $params{META_ADD} if $eumm_version < 6.46;
    delete $params{LICENSE} if $eumm_version < 6.31;
    delete $params{AUTHOR} if $] < 5.005;
    delete $params{ABSTRACT_FROM} if $] < 5.005;
    delete $params{BINARY_LOCATION} if $] < 5.005;

    WriteMakefile(%params);
}

