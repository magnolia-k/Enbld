#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require Enbld::Target::AttributeCollector;

set_http_hook();

my $no = Enbld::Target::AttributeCollector->new;
$no->add( 'IndexSite', 'http://www.example.com' );
$no->add( 'ArchiveName', 'TestApp' );
$no->add( 'Extension', 'tar.gz' );
$no->add( 'IndexParserForm' );
$no->add( 'VersionForm', '\d\.\d' );
$no->add( 'VersionList' );
$no->add( 'SortedVersionList' );
is_deeply( $no->SortedVersionList, [ '1.0', '1.1' ], 'no parameter' );

my $empty_string = Enbld::Target::AttributeCollector->new;
eval { $empty_string->add( 'VersionList', '' ) };
like( $@, qr/ABORT:Attribute 'VersionList' isn't defined/,
        'null string parameter' );

my $empty_array = Enbld::Target::AttributeCollector->new;
$empty_array->add( 'VersionList', [] );
eval { $empty_array->VersionList };
like( $@, qr/ABORT:Attribute 'VersionList' is no version list/,
        'empty array reference parameter' );

my $fixed_string = Enbld::Target::AttributeCollector->new;
$fixed_string->add( 'VersionList', '1.0' );
eval { $fixed_string->VersionList };
like( $@, qr/ABORT:Attribute 'VersionList' isn't ARRAY reference/,
        'fixed string parameter' );

my $fixed_array = Enbld::Target::AttributeCollector->new;
$fixed_array->add( 'VersionList', [ '1.0', '1.1' ] );
is_deeply( \@{ $fixed_array->VersionList }, [ '1.0', '1.1' ],
        'fixed array parameter' );

my $coderef = Enbld::Target::AttributeCollector->new;
$coderef->add( 'VersionList', sub { return [ '1.0', '1.1' ] } );
is_deeply( \@{ $coderef->VersionList }, [ '1.0', '1.1' ],
        'coderef parameter' );

my $space = Enbld::Target::AttributeCollector->new;
$space->add( 'VersionList', [ '1 0' ] );
eval { $space->VersionList };
like( $@, qr/ABORT:Attribute 'VersionList' includes space character/,
        'including space' );

done_testing();

sub set_http_hook {

    my $html = do { local $/; <DATA> };

    require Enbld::HTTP;
    Enbld::HTTP->register_get_hook( sub{ return $html } );
}

__DATA__
<html>
<body>
<a href="TestApp-1.0.tar.gz">TestApp-1.0.tar.gz</a>
<a href="TestApp-1.1.tar.gz">TestApp-1.1.tar.gz</a>
</body>
</html>


