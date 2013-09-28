#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require Enbld::Target::AttributeCollector;
my $testsite = 'http://www.example.com/download/';

my $no = Enbld::Target::AttributeCollector->new;
eval { $no->add( 'DownloadSite' ) };
like( $@, qr/ABORT:Attribute 'DownloadSite' isn't defined/, 'no parameter' );

my $empty = Enbld::Target::AttributeCollector->new;
eval { $empty->add( 'DownloadSite', '' ) };
like( $@, qr/ABORT:Attribute 'DownloadSite' isn't defined/,
        'empty string parameter' );

my $fixed = Enbld::Target::AttributeCollector->new;
$fixed->add( 'DownloadSite', $testsite );
is( $fixed->DownloadSite, $testsite, 'fixed parameter' );

my $coderef = Enbld::Target::AttributeCollector->new;
$coderef->add( 'DownloadSite', sub { return $testsite } );
is( $coderef->DownloadSite, $testsite, 'coderef parameter' );

my $space = Enbld::Target::AttributeCollector->new;
$space->add( 'DownloadSite', 'http://www.example.com/ download/' );
eval { $space->DownloadSite };
like( $@, qr/ABORT:Attribute 'DownloadSite' includes space character/,
          'including space character' );

my $invalid = Enbld::Target::AttributeCollector->new;
$invalid->add( 'DownloadSite', 'ftp://www.example.com/download/' );
eval { $invalid->DownloadSite };
like( $@, qr/ABORT:Attribute 'DownloadSite' isn't valid URL string/,
          'invalid URL string parameter' );

my $noslash = Enbld::Target::AttributeCollector->new;
$noslash->add( 'DownloadSite', 'http://www.example.com/download' );
eval { $noslash->DownloadSite };
like( $@, qr/ABORT:Attribute 'DownloadSite' does not end with slash character/,
                  'invalid end character' );

my $undef = Enbld::Target::AttributeCollector->new;
$undef->add( 'DownloadSite', sub { return } );
eval { $undef->DownloadSite };
like( $@, qr/ABORT:Attribute 'DownloadSite' is empty string/, 'return undef' );

my $array = Enbld::Target::AttributeCollector->new;
$array->add( 'DownloadSite', sub { return [ $testsite ] } );
eval { $array->DownloadSite };
like( $@, qr/ABORT:Attribute 'DownloadSite' isn't scalar value/,
                'return array reference' );

done_testing();
