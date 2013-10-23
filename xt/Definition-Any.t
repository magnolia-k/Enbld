#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;
use Test::Enbld::Definition;

if ( ! $ENV{PERL_ENBLD_TEST_DEFINITION} ) {
    plan skip_all => "Skip build Perl test because none of test env.";
}

my @def_list = qw/
 apache apr aprutil autoconf automake cmake emacs git groff hello
 libevent libidn libtool mysql nginx nodejs pcre perl pkgconfig python
 rakudostar ruby scala tmux tree vim wget zsh/;

for my $def ( @def_list ) {

    build_ok( $def, undef, undef, "build definition '$def'" )
        or diag( "Fail! build definition '$def'." );

}

done_testing();
