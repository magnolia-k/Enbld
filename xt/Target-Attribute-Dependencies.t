#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require Blender::Target::AttributeCollector;

my $no = Blender::Target::AttributeCollector->new;
$no->add( 'Dependencies' );
is_deeply( \@{ $no->Dependencies }, [], 'no parameter' );

my $empty_string = Blender::Target::AttributeCollector->new;
$empty_string->add( 'Dependencies', '' );
eval { $empty_string->Dependencies };
like( $@, qr/ABORT:Attribute 'Dependencies' isn't ARRAY reference/,
        'null string parameter' );

my $empty_array = Blender::Target::AttributeCollector->new;
$empty_array->add( 'Dependencies', [] );
$empty_array->Dependencies;
is_deeply( \@{ $empty_array->Dependencies }, [],
        'empty array reference parameter' );

my $fixed_string = Blender::Target::AttributeCollector->new;
$fixed_string->add( 'Dependencies', 'dependant' );
eval { $fixed_string->Dependencies };
like( $@, qr/ABORT:Attribute 'Dependencies' isn't ARRAY reference/,
        'fixed string parameter' );

my $fixed_array = Blender::Target::AttributeCollector->new;
$fixed_array->add( 'Dependencies', [ 'dependant' ] );
is_deeply( \@{ $fixed_array->Dependencies }, [ 'dependant' ],
        'fixed array parameter' );

my $coderef = Blender::Target::AttributeCollector->new;
$coderef->add( 'Dependencies', sub { return [ 'dependant' ] } );
is_deeply( \@{ $coderef->Dependencies }, [ 'dependant' ],
        'coderef parameter' );

my $space = Blender::Target::AttributeCollector->new;
$space->add( 'Dependencies', [ 'de pe nd an t' ] );
eval { $space->Dependencies };
like( $@, qr/ABORT:Attribute 'Dependencies' includes space character/,
        'including space' );

done_testing();
