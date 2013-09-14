#!/usr/bin/perl

use 5.012;
use warnings;

use File::Spec;
use File::Copy;
use File::Temp;
use FindBin;

use Test::More;

require Blender::Target::AttributeCollector;

my $empty = Blender::Target::AttributeCollector->new;
$empty->add( 'SortedVersionList' );
eval { $empty->add( 'Version', '' ) };
like( $@, qr/ABORT:Attribute 'Version' isn't defined/, 'empty parameter' );

my $fixed = Blender::Target::AttributeCollector->new;
$fixed->add( 'VersionForm', '\d{1,2}\.\d{1,2}(\.\d{1,2})?' );
$fixed->add( 'Version', '1.13.1' );
is( $fixed->Version, '1.13.1', 'fixed parameter' );

my $coderef = Blender::Target::AttributeCollector->new;
$coderef->add( 'VersionForm', '\d{1,2}\.\d{1,2}(\.\d{1,2})?' );
$coderef->add( 'Version', sub { return '1.13.1' } );
is( $coderef->Version, '1.13.1', 'coderef parameter' );

my $invalid = Blender::Target::AttributeCollector->new;
$invalid->add( 'VersionForm', '\d{1,2}\.\d{1,2}(\.\d{1,2})?' );
$invalid->add( 'VersionCondition', undef );
$invalid->add( 'Version', '1.13.100' );
eval { $invalid->Version };
like( $@, qr/NOT valid version string/, 'invalid parameter' );

my $space = Blender::Target::AttributeCollector->new;
$space->add( 'VersionForm', '\d{1,2}\.\d{1,2}(\.\d{1,2})?' );
$space->add( 'Version', '1. 3.1' );
eval { $space->Version };
like( $@, qr/ABORT:Attribute 'Version' includes space character/,
                'including space' );

my $undef = Blender::Target::AttributeCollector->new;
$undef->add( 'VersionForm', '\d{1,2}\.\d{1,2}(\.\d{1,2})?' );
$undef->add( 'Version', sub { return } );
eval { $undef->Version };
like( $@, qr/ABORT:Attribute 'Version' is empty string/, 'return undef' );

my $array = Blender::Target::AttributeCollector->new;
$array->add( 'VersionForm', '\d{1,2}\.\d{1,2}(\.\d{1,2})?' );
$array->add( 'Version', sub { return [ '1.13.1' ] } );
eval { $array->Version };
like( $@, qr/ABORT:Attribute 'Version' isn't scalar value/,
                'return array reference' );

subtest 'invalid Version Condition' => sub {
    set_http_hook();

    my $invalid_condition = Blender::Target::AttributeCollector->new;
    $invalid_condition->add( 'IndexSite', 'http://www.example.com' );
    $invalid_condition->add( 'VersionForm', '\d\.\d' );
    $invalid_condition->add( 'AllowedCondition' );
    $invalid_condition->add( 'ArchiveName', 'TestApp' );
    $invalid_condition->add( 'Extension', 'tar.gz' );
    $invalid_condition->add( 'IndexParserForm' );
    $invalid_condition->add( 'VersionCondition', '1.2' );
    $invalid_condition->add( 'VersionList' );
    $invalid_condition->add( 'SortedVersionList' );
    $invalid_condition->add( 'Version' );

    eval{ $invalid_condition->Version };
    like( $@, qr/ERROR:Invalid Version Condition:1/, 'invalid condition' );

    done_testing();
};

done_testing();

sub set_http_hook {

    my $html = do { local $/; <DATA> };

    require Blender::HTTP;
    Blender::HTTP->register_get_hook( sub{ return $html } );
}

__DATA__
<html>
<body>
<a href="TestApp-1.0.tar.gz">TestApp-1.0.tar.gz</a>
<a href="TestApp-1.1.tar.gz">TestApp-1.1.tar.gz</a>
</body>
</html>


