#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require Blender::Target::AttributeCollector;

my $no = Blender::Target::AttributeCollector->new;
$no->add( 'AllowedCondition' );
is( $no->AllowedCondition, '', 'no parameter' );

my $empty = Blender::Target::AttributeCollector->new;
$empty->add( 'AllowedCondition', '' );
is( $empty->AllowedCondition, '', 'empty parameter' );

my $fixed = Blender::Target::AttributeCollector->new;
$fixed->add( 'AllowedCondition', 'development' );
is( $fixed->AllowedCondition, "development", 'fixed parameter' );

my $coderef = Blender::Target::AttributeCollector->new;
$coderef->add( 'AllowedCondition', sub { return 'development' } );
is( $coderef->AllowedCondition, "development", 'coderef parameter' );

my $space = Blender::Target::AttributeCollector->new;
$space->add( 'AllowedCondition', 'd e v e l o p m e n t' );
eval { $space->AllowedCondition };
like( $@, qr/ABORT:Attribute 'AllowedCondition' includes space character/,
        'including space' );

my $undef = Blender::Target::AttributeCollector->new;
$undef->add( 'AllowedCondition', sub { return } );
is( $undef->AllowedCondition, '', 'return undef' );

my $array = Blender::Target::AttributeCollector->new;
$array->add( 'AllowedCondition', sub { return [ 'development' ] } );
eval { $array->AllowedCondition };
like( $@, qr/ABORT:Attribute 'AllowedCondition' isn't scalar value/,
                'return array reference' );

done_testing();
