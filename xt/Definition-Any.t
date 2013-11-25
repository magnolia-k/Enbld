#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;
use Test::Enbld::Definition;

if ( ! $ENV{PERL_ENBLD_TEST_DEFINITION} ) {
    plan skip_all => "Skip build test because none of test env.";
}

my @def_list = qw/
 apr aprutil apache autoconf automake cmake emacs git groff hello
 libevent libidn libtool mysql nginx nodejs pcre perl pkgconfig python
 rakudostar ruby scala tmux tree vim wget zsh openssl/;

for my $def ( @def_list ) {

    local $ENV{PERL_ENBLD_HOME} = File::Temp->newdir;

    Enbld::Home->initialize;
    Enbld::Home->create_build_directory;
    Enbld::Logger->rotate( Enbld::Home->log );


    my $target = Enbld::Target->new( $def );
    my $installed = eval { $target->install };

    ok( $installed, "build $def" ) or diag( $@ );
}

done_testing();
