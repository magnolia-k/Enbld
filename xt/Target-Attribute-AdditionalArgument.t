#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require Blender::Target::AttributeCollector;

my $no = Blender::Target::AttributeCollector->new;
$no->add( 'AdditionalArgument' );
is( $no->AdditionalArgument, '', 'no parameter' );

my $empty = Blender::Target::AttributeCollector->new;
$empty->add( 'AdditionalArgument', '' );
is( $empty->AdditionalArgument, '', 'null parameter' );

my $fixed = Blender::Target::AttributeCollector->new;
$fixed->add( 'AdditionalArgument', 'argument' );
is( $fixed->AdditionalArgument, 'argument', 'fixed parameter' );

my $coderef = Blender::Target::AttributeCollector->new;
$coderef->add( 'AdditionalArgument', sub { return 'argument' } );
is( $coderef->AdditionalArgument, 'argument', 'coderef parameter' );

my $space = Blender::Target::AttributeCollector->new;
$space->add( 'AdditionalArgument', 'a r g s' );
is( $space->AdditionalArgument, 'a r g s', 'including space' );

my $undef = Blender::Target::AttributeCollector->new;
$undef->add( 'AdditionalArgument', sub { return } );
is( $undef->AdditionalArgument, '', 'return undef' );

my $array = Blender::Target::AttributeCollector->new;
$array->add( 'AdditionalArgument', sub { return [ 'argument' ] } );
eval { $array->AdditionalArgument};
like( $@, qr/ABORT:Attribute 'AdditionalArgument' isn't scalar value/,
                'return array reference' );

done_testing();
