#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require Enbld::Target::AttributeCollector;

my $file = 'archive-1.10.tar.gz';

my $no = Enbld::Target::AttributeCollector->new;
$no->add( 'ArchiveName', 'archive' );
$no->add( 'Version', '1.10' );
$no->add( 'Extension', 'tar.gz' );
$no->add( 'VersionForm', '\d{1,2}\.\d{1,2}(\.\d{1,2})?' );
$no->add( 'Filename' );
is( $no->Filename, $file, 'no parameter' );

my $empty = Enbld::Target::AttributeCollector->new;
eval { $empty->add( 'Filename', '' ) };
like( $@, qr/ABORT:Attribute 'Filename' isn't defined/, 'empty parameter' );

my $fixed = Enbld::Target::AttributeCollector->new;
$fixed->add( 'Filename', $file );
is( $fixed->Filename, $file, 'fixed parameter' );

my $coderef = Enbld::Target::AttributeCollector->new;
$coderef->add( 'Filename', sub { return $file } );
is( $coderef->Filename, $file, 'coderef parameter' );

my $space = Enbld::Target::AttributeCollector->new;
$space->add( 'Filename', 'archive 1.10 tar.gz' );
eval { $space->Filename };
like( $@, qr/ABORT:Attribute 'Filename' includes space character/,
        'including space character' );

my $undef = Enbld::Target::AttributeCollector->new;
$undef->add( 'Filename', sub { return } );
eval { $undef->Filename };
like( $@, qr/ABORT:Attribute 'Filename' is empty string/, 'return undef' );

my $array = Enbld::Target::AttributeCollector->new;
$array->add( 'Filename', sub { return [ $file ] } );
eval { $array->Filename };
like( $@, qr/ABORT:Attribute 'Filename' isn't scalar value/,
                'return array reference' );

done_testing();
