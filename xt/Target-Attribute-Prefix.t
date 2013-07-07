#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require Blender::Target::AttributeCollector;

my $no = Blender::Target::AttributeCollector->new;
$no->add( 'Prefix' );
is( $no->Prefix, '--prefix=', 'no parameter' );

my $empty = Blender::Target::AttributeCollector->new;
eval { $empty->add( 'Prefix', '' ) };
like( $@, qr/ABORT:Attribute 'Prefix' isn't defined/, 'null parameter' );

my $fixed = Blender::Target::AttributeCollector->new;
$fixed->add( 'Prefix', '--PREFIX=' );
is( $fixed->Prefix, '--PREFIX=', 'fixed parameter' );

my $coderef = Blender::Target::AttributeCollector->new;
$coderef->add( 'Prefix', sub { return '--PREFIX=' } );
is( $coderef->Prefix, '--PREFIX=', 'coderef parameter' );

my $space = Blender::Target::AttributeCollector->new;
$space->add( 'Prefix', '--PREFIX =' );
eval { $space->Prefix };
like( $@, qr/ABORT:Attribute 'Prefix' includes space character/,
                'including space' );

my $undef = Blender::Target::AttributeCollector->new;
$undef->add( 'Prefix', sub { return } );
eval { $undef->Prefix };
like( $@, qr/ABORT:Attribute 'Prefix' is empty string/, 'return undef' );

my $array = Blender::Target::AttributeCollector->new;
$array->add( 'Prefix', sub { return [ '--PREFIX=' ] } );
eval { $array->Prefix };
like( $@, qr/ABORT:Attribute 'Prefix' isn't scalar value/,
                'return array reference' );

done_testing();
