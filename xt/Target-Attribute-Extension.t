#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require Enbld::Target::AttributeCollector;

my $no = Enbld::Target::AttributeCollector->new;
$no->add( 'Extension' );
is( $no->Extension, 'tar.gz', 'no parameter' );

my $empty = Enbld::Target::AttributeCollector->new;
eval { $empty->add( 'Extension', '' ) };
like( $@, qr/ABORT:Attribute 'Extension' isn't defined/, 'null parameter' );

my $fixed = Enbld::Target::AttributeCollector->new;
$fixed->add( 'Extension', 'tgz' );
is( $fixed->Extension, 'tgz', 'fixed parameter' );

my $coderef = Enbld::Target::AttributeCollector->new;
$coderef->add( 'Extension', sub { return 'tgz' } );
is( $coderef->Extension, 'tgz', 'coderef parameter' );

my $invalid = Enbld::Target::AttributeCollector->new;
$invalid->add( 'Extension', 'lzh' );
eval { $invalid->Extension };
like( $@, qr/Attribute 'Extension' is invalid string/, 'invalid parameter' );

my $space = Enbld::Target::AttributeCollector->new;
$space->add( 'Extension', 't g z' );
eval { $space->Extension };
like( $@, qr/ABORT:Attribute 'Extension' includes space character/,
          'including space' );

my $undef = Enbld::Target::AttributeCollector->new;
$undef->add( 'Extension', sub { return } );
eval { $undef->Extension };
like( $@, qr/ABORT:Attribute 'Extension' is empty string/, 'return undef' );

my $array = Enbld::Target::AttributeCollector->new;
$array->add( 'Extension', sub { return [ 'tgz' ] } );
eval { $array->Extension };
like( $@, qr/ABORT:Attribute 'Extension' isn't scalar value/,
                'return array reference' );

done_testing();
