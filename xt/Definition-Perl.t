#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;
use Test::Blender::Definition;

require Blender::Condition;
my $condition = Blender::Condition->new(
        name    => 'perl',
        modules =>  { 'App::cpanminus' => 0 },
        );

SKIP: {
          skip "Skip build Perl test because none of test env.",
               2 unless ( $ENV{PERL_BLENDER_TEST_DEFINITION} );
          
          build_ok( 'perl', undef, undef, 'first test' );

          build_ok( 'perl', undef, $condition, 'install module test' );
      };

done_testing();
