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

my $dev = Blender::Condition->new(
        name    => 'perl',
        version => 'development',
        );

SKIP: {
          skip "Skip build Perl test because none of test env.",
               3 unless ( $ENV{PERL_BLENDER_TEST_DEFINITION} );
          
          build_ok( 'perl', undef, undef, 'first test' );

          build_ok( 'perl', undef, $dev, 'install development version' );

          build_ok( 'perl', undef, $condition, 'install module test' );
      };

done_testing();
