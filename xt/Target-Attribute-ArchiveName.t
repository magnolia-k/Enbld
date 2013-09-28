#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require Enbld::Target::AttributeCollector;

my $no = Enbld::Target::AttributeCollector->new;
eval { $no->add( 'ArchiveName' ) };
like( $@, qr/ABORT:Attribute 'ArchiveName' isn't defined/, 'no parameter' );

my $empty = Enbld::Target::AttributeCollector->new;
eval { $empty->add( 'ArchiveName', '' ) };
like( $@, qr/ABORT:Attribute 'ArchiveName' isn't defined/, 'null parameter' );

my $fixed = Enbld::Target::AttributeCollector->new;
$fixed->add( 'ArchiveName', 'archive' );
is( $fixed->ArchiveName, 'archive', 'fixed parameter' );

my $coderef = Enbld::Target::AttributeCollector->new;
$coderef->add( 'ArchiveName', sub { return 'archive' } );
is( $coderef->ArchiveName, 'archive', 'coderef parameter' );

my $space = Enbld::Target::AttributeCollector->new;
$space->add( 'ArchiveName', 'a r c h i v e' );
eval { $space->ArchiveName };
like( $@, qr/ABORT:Attribute 'ArchiveName' includes space character/,
        'including space' );

my $undef = Enbld::Target::AttributeCollector->new;
$undef->add( 'ArchiveName', sub { return } );
eval { $undef->ArchiveName };
like( $@, qr/ABORT:Attribute 'ArchiveName' is empty string/, 'return undef' );

my $array = Enbld::Target::AttributeCollector->new;
$array->add( 'ArchiveName', sub { return [ 'archive' ] } );
eval { $array->ArchiveName };
like( $@, qr/ABORT:Attribute 'ArchiveName' isn't scalar value/,
        'return array reference' );

done_testing();
