#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require_ok( 'Enbld::Condition' );

subtest 'getter method' => sub {
    subtest 'set version' => sub {
        my $condition = Enbld::Condition->new( version => '1.0' );
        is( $condition->version, '1.0', 'version' );

        done_testing();
    };

    subtest 'no version' => sub {
        my $condition = Enbld::Condition->new;
        is( $condition->version, 'latest', 'version' );

        done_testing();
    };

    subtest 'set make_test' => sub {
        my $condition = Enbld::Condition->new( make_test => 1 );
        is( $condition->make_test, 1, 'make test' );

        done_testing();
    };

    subtest 'no make_test' => sub {
        my $condition = Enbld::Condition->new;
        is( $condition->make_test, undef, 'no make test' );

        done_testing();
    };

    done_testing();
};

subtest 'serialize' => sub {

    subtest 'defined serialize' => sub {
        my $condition = Enbld::Condition->new( make_test => 1 );

        is_deeply(
                $condition->serialize, { version => 'latest', make_test => 1 },
                'serialized version'
                );

        done_testing();
    };

    subtest 'not defined serialize' => sub {
        my $condition = Enbld::Condition->new;

        is_deeply(
                $condition->serialize, { version => 'latest' },
                'serialized version'
                );

        done_testing();
    };

    subtest 'modules serialize' => sub {
        my $condition = Enbld::Condition->new( modules => {
                module_a    => 0,
                module_b    => 0,
                });

        is_deeply(
                $condition->serialize,
                {
                version => 'latest',
                modules => {
                module_a => 0,
                module_b => 0,
                }},
                'serialized modules'
                );

        done_testing();
    };

    done_testing();
};

subtest 'is_equal_to method' => sub {

    subtest 'condition check' => sub {
        my $condition = Enbld::Condition->new( version => 'latest' );
        my $param     = Enbld::Condition->new( version => 'latest' );

        is( $condition->is_equal_to( $param ), $condition, 'same version' );

        my $param_diff = Enbld::Condition->new( version => '1.0' );

        is( $condition->is_equal_to( $param_diff ), undef,
                'different version' );

        done_testing();
    };

    subtest 'make_test check' => sub {

        my $condition = Enbld::Condition->new( make_test => 1 );
        my $param     = Enbld::Condition->new( make_test => 1 );

        is( $condition->is_equal_to( $param ), $condition, 'same make_test' );

        my $param_diff = Enbld::Condition->new( make_test => undef );

        is( $condition->is_equal_to( $param_diff ), undef,
                'different make_test' );

        my $condition_diff = Enbld::Condition->new( make_test => undef );

        is( $condition_diff->is_equal_to( $param ), undef,
                'different not equal pattern' );

        done_testing();
    };

    subtest 'modules check' => sub {

        my $condition = Enbld::Condition->new( modules => { module => 0 } );
        my $param     = Enbld::Condition->new( modules => { module => 0 } );

        is( $condition->is_equal_to( $param ), $condition, 'same modules' );

        my $param_diff = Enbld::Condition->new( modules => undef );

        is( $condition->is_equal_to( $param_diff ), undef,
                'different modules pattern1' );

        my $condition_diff = Enbld::Condition->new( modules => undef );

        is( $condition_diff->is_equal_to( $param ), undef,
                'diffrent modules pattern2' );

        my $param_diff_but_modules = Enbld::Condition->new(
                modules => { 'diffrentmodule' => 0 },
                );

        is( $condition->is_equal_to( $param_diff_but_modules ), undef,
                'different module condition' );

        done_testing();
    };

    done_testing();
};

done_testing();
