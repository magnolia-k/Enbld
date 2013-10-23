#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;
use Test::Enbld::Definition;

if ( ! $ENV{PERL_ENBLD_TEST_DEFINITION} ) {
    plan skip_all => "Skip build Perl test because none of test env.";
}

require Enbld::Condition;
my $install_modules = {
    perl => Enbld::Condition->new( modules =>  { 'App::cpanminus' => 0 } ),
        };

my $install_dev_ver = {
    perl => Enbld::Condition->new( version => 'development' ),
};

build_ok( 'perl', undef, undef,             'build latest version'  );
build_ok( 'perl', undef, $install_dev_ver,  'build dev version'     );
build_ok( 'perl', undef, $install_modules,  'install modules'       );

done_testing();
