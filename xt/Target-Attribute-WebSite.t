#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require Blender::Target::AttributeCollector;
my $testsite = 'http://www.example.com/';

my $no = Blender::Target::AttributeCollector->new;
eval { $no->add( 'WebSite' ) };
like( $@, qr/ABORT:Attribute 'WebSite' isn't defined/, 'no parameter' );

my $empty = Blender::Target::AttributeCollector->new;
eval { $empty->add( 'WebSite', '' ) };
like( $@, qr/ABORT:Attribute 'WebSite' isn't defined/,
        'empty string parameter' );

my $fixed = Blender::Target::AttributeCollector->new;
$fixed->add( 'WebSite', $testsite );
is( $fixed->WebSite, $testsite, 'fixed parameter' );

my $coderef = Blender::Target::AttributeCollector->new;
$coderef->add( 'WebSite', sub { return $testsite } );
is( $coderef->WebSite, $testsite, 'coderef parameter' );

my $space = Blender::Target::AttributeCollector->new;
$space->add( 'WebSite', 'http://www. example. com/' );
eval { $space->WebSite };
like( $@, qr/ABORT:Attribute 'WebSite' includes space character/,
          'including space character' );

my $invalid = Blender::Target::AttributeCollector->new;
$invalid->add( 'WebSite', 'ftp://www.example.com/' );
eval { $invalid->WebSite };
like( $@, qr/ABORT:Attribute 'WebSite' isn't valid URL string/,
          'invalid URL string parameter' );

my $undef = Blender::Target::AttributeCollector->new;
$undef->add( 'WebSite', sub { return } );
eval { $undef->WebSite };
like( $@, qr/ABORT:Attribute 'WebSite' is empty string/, 'return undef' );

my $array = Blender::Target::AttributeCollector->new;
$array->add( 'WebSite', sub { return [ $testsite ] } );
eval { $array->WebSite };
like( $@, qr/ABORT:Attribute 'WebSite' isn't scalar value/,
                'return array reference' );

done_testing();
