#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;
use Test::Enbld::Definition;

require Enbld::Condition;
my $condition = {
    perl => Enbld::Condition->new( modules =>  { 'App::cpanminus' => 0 } ),
        };

my $dev = {
    perl => Enbld::Condition->new( version => 'development' ),
};

SKIP: {
          skip "Skip build Perl test because none of test env.",
               3 unless ( $ENV{PERL_ENBLD_TEST_DEFINITION} );
          
          build_ok( 'perl', undef, undef, 'first test' );

          build_ok( 'perl', undef, $dev, 'install development version' );

          build_ok( 'perl', undef, $condition, 'install module test' );
      };

done_testing();
