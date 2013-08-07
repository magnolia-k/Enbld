#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require_ok( 'Blender::Condition' );
require_ok( 'Blender::ConditionCollector' );

subtest 'constructor method' => sub {
    eval { Blender::Condition->new };
    like( $@, qr/ABORT:'Blender::Condition' requires name/, 'construct fail' );

    done_testing();
};

subtest 'getter method' => sub {
    subtest 'set version' => sub {
        my $condition = Blender::Condition->new(
                name => 'app',
                version => '1.0'
                );
        is( $condition->name, 'app', 'name' );
        is( $condition->version, '1.0', 'version' );

        done_testing();
    };

    subtest 'no version' => sub {
        my $condition = Blender::Condition->new( name => 'app' );
        is( $condition->name, 'app', 'name' );
        is( $condition->version, 'latest', 'version' );

        done_testing();
    };

    subtest 'set make_test' => sub {
        my $condition = Blender::Condition->new(
                name        =>  'app',
                make_test   =>  1,
                );
        is( $condition->make_test, 1, 'make test' );

        done_testing();
    };

    subtest 'no make_test' => sub {
        my $condition = Blender::Condition->new( name => 'app' );
        is( $condition->make_test, undef, 'make test' );

        done_testing();
    };

    done_testing();
};

subtest 'serialize' => sub {

    subtest 'defined serialize' => sub {
        my $condition = Blender::Condition->new(
                name        => 'app',
                make_test   => 1,
                );

        is_deeply(
                $condition->serialize,
                { name => 'app', version => 'latest', make_test => 1 },
                'serialized'
                );

        is_deeply(
                $condition->serialize_without_name,
                { version => 'latest', make_test => 1 },
                'serialized without name'
                );

        done_testing();
    };

    subtest 'not defined serialize' => sub {
        my $condition = Blender::Condition->new(
                name => 'app', make_test => undef
                );

        is_deeply(
                $condition->serialize,
                { name => 'app', version => 'latest' },
                'serialized'
                );

        is_deeply(
                $condition->serialize_without_name,
                { version => 'latest' },
                'serialized without name'
                );

        done_testing();
    };

    done_testing();
};

subtest 'collector method' => sub {

    subtest 'get collection' => sub {
        my $condition = Blender::Condition->new( name => 'app' );
        Blender::ConditionCollector->add( $condition );
        my $collection = Blender::ConditionCollector->collection;

        ok( exists $collection->{app}, 'collection method' );

        Blender::ConditionCollector->destroy;

        done_testing();
    };

    subtest 'no return' => sub {
        is( Blender::ConditionCollector->search, undef, 'no param' );

        done_testing();
    };

    subtest 'method success' => sub {
        my $condition = Blender::Condition->new( name => 'app' );
        Blender::ConditionCollector->add( $condition );
        
        my $searched = Blender::ConditionCollector->search( 'app' );
        is( $searched->name, 'app', 'got name' );
        is( $searched->version, 'latest', 'got enabled' );

        done_testing();
    };

    subtest 'no config' => sub {
        is(
                Blender::ConditionCollector->search( 'dummy' ),
                undef,
                'no condition'
                );

        done_testing();
    };

    subtest 'add method exception - no param' => sub {
        eval { Blender::ConditionCollector->add };
        like( $@, qr/ABORT:add method requires condition object/, 'no param' );

        done_testing();
    };

    subtest 'add method exception - duplicate object' => sub {
        no Blender::ConditionCollector;
        require Blender::ConditionCollector;

        my $condition = Blender::Condition->new( name => 'target' );
        Blender::ConditionCollector->add( $condition );

        eval { Blender::ConditionCollector->add( $condition ) };
        like( $@, qr/ABORT:target is already added/, 'duplicate' );

        done_testing();
    };

    done_testing();
};

subtest 'is_equal_to method' => sub {

    subtest 'no parameter' => sub {
        my $condition = Blender::Condition->new( name => 'target' );
        eval { $condition->is_equal_to };

        like( $@, qr/is_equal_to method requires Blender::Condition object/,
                'no parameter' );

        done_testing();
    };

    subtest 'different target name' => sub {
        my $condition = Blender::Condition->new( name => 'testapp' );
        my $param     = Blender::Condition->new( name => 'difference' );

        eval { $condition->is_equal_to( $param ) };

        like( $@, qr/is_equal_to method requires same target condition/,
                'diffrent target' );

        done_testing();
    };

    subtest 'condition check' => sub {
        my $condition = Blender::Condition->new(
                name    => 'testapp',
                version => 'latest',
                );

        my $param     = Blender::Condition->new(
                name => 'testapp',
                version => 'latest',
                );

        is( $condition->is_equal_to( $param ), $condition, 'same version' );

        my $param_diff = Blender::Condition->new(
                name => 'testapp',
                version => '1.0',
                );

        is( $condition->is_equal_to( $param_diff ), undef,
                'different version' );

        done_testing();
    };

    subtest 'make_test check' => sub {

        my $condition = Blender::Condition->new(
                name        => 'testapp',
                make_test   => 1,
                );

        my $param     = Blender::Condition->new(
                name => 'testapp',
                make_test   => 1,
                );

        is( $condition->is_equal_to( $param ), $condition, 'same make_test' );

        my $param_diff = Blender::Condition->new(
                name        => 'testapp',
                make_test   => undef,
                );

        is( $condition->is_equal_to( $param_diff ), undef,
                'different make_test' );

        my $condition_diff = Blender::Condition->new(
                name        => 'testapp',
                make_test   => undef,
                );

        is( $condition_diff->is_equal_to( $param ), undef,
                'different not equal pattern' );

        done_testing();
    };

    subtest 'modules check' => sub {

        my $condition = Blender::Condition->new(
                name        => 'testapp',
                modules     =>  { module => 0 },
                );

        my $param     = Blender::Condition->new(
                name => 'testapp',
                modules     =>  { module => 0 },
                );

        is( $condition->is_equal_to( $param ), $condition, 'same modules' );

        my $param_diff = Blender::Condition->new(
                name    => 'testapp',
                modules => undef,
                );

        is( $condition->is_equal_to( $param_diff ), undef,
                'different modules pattern1' );

        my $condition_diff = Blender::Condition->new(
                name        => 'testapp',
                modules     => undef,
                );

        is( $condition_diff->is_equal_to( $param ), undef,
                'diffrent modules pattern2' );

        my $param_diff_but_modules = Blender::Condition->new(
                name    => 'testapp',
                modules => { 'diffrentmodule' => 0 },
                );

        is( $condition->is_equal_to( $param_diff_but_modules ), undef,
                'different module condition' );

        done_testing();
    };

    

    done_testing();
};

subtest 'modules method test' => sub {

    subtest 'modules parameter' => sub {
        my $condition = Blender::Condition->new(
                name => 'testapp',
                modules => +{ module => 0 }
                );

        is_deeply( $condition->modules, +{ module => 0 }, 'modules parameter' );

        done_testing();
    };



    subtest 'invalid modules parameter' => sub {
        eval {
            Blender::Condition->new(
                    name    => 'testapp',
                    modules => [ 'module' ],
                    );
        };

        like( $@, qr/ERROR:condition 'modules' must be hash ref/,
                'invalid parameter' );

        done_testing();
    };

    subtest 'empty modules parameter' => sub {
        my $con = Blender::Condition->new( name => 'testapp', modules => {} );

        is_deeply( $con->modules, +{}, 'empty modules parameter' );

        done_testing();
    };

    subtest 'version is undef' => sub {
        eval {
            Blender::Condition->new(
                    name    => 'testapp',
                    modules => { 'module' => undef },
                    );
        };

        like( $@, qr/ERROR:module's version isn't set/,
                'version is undef' );

        done_testing();
    };

    subtest 'version is not scalar' => sub {
        eval {
            Blender::Condition->new(
                    name    => 'testapp',
                    modules => { 'module' => +{} },
                    );
        };

        like( $@, qr/ERROR:module's version must be a scalar/,
                'version is not scalar' );

        done_testing();
    };



    done_testing();
};

done_testing();
