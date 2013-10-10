use 5.006;
use strict;
use warnings;

use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Enbld',
    license             => 'perl',
    dist_author         => q{magnolia <magnolia.k@me.com>},
    dist_abstract       => 'Build your development environment by perl-based DSL',
    dist_version_from   => 'lib/Enbld.pm',
    release_status      => 'stable',
    requires            => {
        'perl'              => 5.012,
    },

    add_to_cleanup      => [ 'Enbld-*' ],
    create_makefile_pl  => 'traditional',
);

$builder->create_build_script();
