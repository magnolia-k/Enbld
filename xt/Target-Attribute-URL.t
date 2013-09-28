#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require Enbld::Target::AttributeCollector;

my $url = 'http://www.example.com/file-1.0.tar.gz';

my $no = Enbld::Target::AttributeCollector->new;
$no->add( 'DownloadSite', 'http://www.example.com/' );
$no->add( 'Filename', 'file-1.0.tar.gz' );
$no->add( 'URL' );
is( $no->URL, $url, 'no parameter' );

my $empty = Enbld::Target::AttributeCollector->new;
eval { $empty->add( 'URL', '' ) };
like( $@, qr/ABORT:Attribute 'URL' isn't defined/, 'empty parameter' );

my $fixed = Enbld::Target::AttributeCollector->new;
$fixed->add( 'URL', $url );
is( $fixed->URL, $url, 'fixed parameter' );

my $coderef = Enbld::Target::AttributeCollector->new;
$coderef->add( 'URL', sub { return $url } );
is( $coderef->URL, $url, 'coderef parameter' );

my $space = Enbld::Target::AttributeCollector->new;
$space->add( 'URL', 'http://www.example.com /file-1.0.tar.gz' );
eval { $space->URL };
like( $@, qr/ABORT:Attribute 'URL' includes space character/,
                'including space' );

my $undef = Enbld::Target::AttributeCollector->new;
$undef->add( 'URL', sub { return } );
eval { $undef->URL };
like( $@, qr/ABORT:Attribute 'URL' is empty string/, 'return undef' );

my $array = Enbld::Target::AttributeCollector->new;
$array->add( 'URL', sub { return [ $url ] } );
eval { $array->URL };
like( $@, qr/ABORT:Attribute 'URL' isn't scalar value/,
                'return array reference' );

done_testing();
