#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require_ok( 'Blender::HTML' );

my $html = Blender::HTML->new( do { local $/; <DATA> } );

my $list = $html->parse_version(
        '<a href="http://www.example.com/archive-\d\.\d{2}\.tar\.gz">',
        '\d\.\d{2}'
        );

ok( grep { $_ eq '1.10' } @{ $list} , 'version exists' );

my $empty = Blender::HTML->new( '' );
my $empty_list = $empty->parse_version(
        '<a href="http://www.example.com/archive-\d\.\d{2}\.tar\.gz',
        '\d\.\d{2}'
        );

is( $empty_list, undef, q{can't parse version string} );

done_testing();

__DATA__
<html>
<body>
<a href="http://www.example.com/archive-1.00.tar.gz">archive-1.00.tar.gz</a>
<a href="http://www.example.com/archive-1.10.tar.gz">archive-1.10.tar.gz</a>
</body>
</html>
