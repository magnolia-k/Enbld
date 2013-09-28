#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

my $index = 'http://www.example.com/download/';

require Enbld::Target::AttributeCollector;

my $no = Enbld::Target::AttributeCollector->new;
$no->add( 'DownloadSite', $index );
$no->add( 'IndexSite' );
is( $no->IndexSite, $index, 'no parameter' );

my $empty = Enbld::Target::AttributeCollector->new;
eval { $empty->add( 'IndexSite', '' ) };
like( $@, qr/ABORT:Attribute 'IndexSite' isn't defined/, 'empty string' );

my $fixed = Enbld::Target::AttributeCollector->new;
$fixed->add( 'IndexSite', $index );
is( $fixed->IndexSite, $index, 'fixed parameter' );

my $coderef = Enbld::Target::AttributeCollector->new;
$coderef->add( 'IndexSite', sub { return $index } );
is( $coderef->IndexSite, $index, 'coderef parameter' );

my $space = Enbld::Target::AttributeCollector->new;
$space->add( 'IndexSite', 'http://www.example.com  /download/' );
eval { $space->IndexSite };
like( $@, qr/ABORT:Attribute 'IndexSite' includes space character/,
          'including space character' );

my $invalid = Enbld::Target::AttributeCollector->new;
$invalid->add( 'IndexSite', 'ftp://www.example.com/download/' );
eval { $invalid->IndexSite };
like( $@, qr/ABORT:Attribute 'IndexSite' isn't valid URL string/,
                  'invalid URL string parameter' );

my $noslash = Enbld::Target::AttributeCollector->new;
$noslash->add( 'IndexSite', 'http://www.example.com/download' );
is( $noslash->IndexSite, 'http://www.example.com/download',
        'end with no slash URL' );

my $undef = Enbld::Target::AttributeCollector->new;
$undef->add( 'IndexSite', sub { return } );
eval { $undef->IndexSite };
like( $@, qr/ABORT:Attribute 'IndexSite' is empty string/, 'return undef' );

my $array = Enbld::Target::AttributeCollector->new;
$array->add( 'IndexSite', sub { return [ $index ] } );
eval { $array->IndexSite };
like( $@, qr/ABORT:Attribute 'IndexSite' isn't scalar value/,
                'return array reference' );

done_testing();
