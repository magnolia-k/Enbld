use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Blender::Declare',
    license             => 'artistic_2',
    dist_author         => q{magnolia <magnolia.k@me.com>},
    dist_abstract       => 'build up your development environment',
    dist_version        => '0.60',
    release_status      => 'testing',
    requires            => {
        'perl'              => 5.012,
    },

    add_to_cleanup      => [ 'Blender-Declare-*' ],
    create_makefile_pl  => 'traditional',
);

$builder->create_build_script();
