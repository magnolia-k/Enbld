#!/usr/bin/perl

use 5.012;
use warnings;

use autodie;
use File::Temp;
use File::Spec;

use Test::More;

require_ok( 'Blender::RcFile' );

subtest 'set contents' => sub {
    my $dir = File::Temp->newdir;
    my $filename = '.blendrc';
    my $fullpath = File::Spec->catfile( $dir, $filename );

    my $rcfile = Blender::RcFile->new(
            filepath    =>  $filename,
            directory   =>  $dir,
            contents    =>  'blender',
            command     =>  'set',
            );

    is( $rcfile->do, $filename, 'set rcfile' );

    ok( -e $fullpath, 'create rc file' );
    
    open my $fh, '<', $fullpath;
    my $content = do { local $/; <$fh> };
    close $fh;

    like( $content, qr/blender/, 'contents' );

    my @DSL;
    push @DSL, "conf '.blendrc' => set {\n";
    push @DSL, "    to '" . $dir . "';\n";
    push @DSL, "    content 'blender';\n";
    push @DSL, "};\n";

    my $DSLed = $rcfile->DSL;

    is_deeply( $DSLed, \@DSL, 'DSL' );

    my $serialized = $rcfile->serialize;

    is_deeply( $serialized,
            {
            filepath    => $filename,
            command     => 'set',
            contents    => "blender",
            directory   => $dir,
            },
            'serialized' );

    done_testing();
};

SKIP: {
          skip "Skip RcFile test because none of test env.",
               2 unless ( $ENV{PERL_BLENDER_TEST} );

          subtest 'load conf' => sub {
              my $dir = File::Temp->newdir;
              my $filepath = '.vimrc';
              my $fullpath = File::Spec->catfile( $dir, $filepath );
              my $url = 'https://raw.github.com/magnolia-k/vimrc/master/.vimrc';

              my $rcfile = Blender::RcFile->new(
                      filepath  =>  $filepath,
                      directory =>  $dir,
                      url       =>  $url,
                      command   =>  'load',
                      );
              
              is( $rcfile->do, $filepath, 'set rcfile' );
              ok( -e $fullpath, 'create rc file' );
              
              open my $fh, '<', $fullpath;
              my $content = do { local $/; <$fh> };
              close $fh;
              
              like( $content, qr/syntax on/, 'contents' );

              my $DSLed = $rcfile->DSL;

              like( $DSLed->[0], qr/load/, 'DSL' );
              
              my $serialized = $rcfile->serialize;

              is( $serialized->{filepath},  $filepath, 'filepath'  );
              is( $serialized->{command},   'load',    'command'   );
              is( $serialized->{directory}, $dir,      'directory' );
              is( $serialized->{contents},  undef,     'contents'  );

              done_testing();
          };

          subtest 'load and set conf' => sub {
              my $dir = File::Temp->newdir;
              my $filepath = '.vimrc';
              my $fullpath = File::Spec->catfile( $dir, $filepath );
              my $url = 'https://raw.github.com/magnolia-k/vimrc/master/.vimrc';

              my $rcfile = Blender::RcFile->new(
                      filepath  =>  $filepath,
                      directory =>  $dir,
                      url       =>  $url,
                      contents  =>  'contents',
                      command   =>  'load',
                      );
              
              is( $rcfile->do, $filepath, 'set rcfile' );
              ok( -e $fullpath, 'create rc file' );
              
              open my $fh, '<', $fullpath;
              my $content = do { local $/; <$fh> };
              close $fh;
              
              like( $content, qr/content/, 'contents' );

              my $DSLed = $rcfile->DSL;

              like( $DSLed->[0], qr/load/, 'DSL' );

              my $serialized = $rcfile->serialize;

              is( $serialized->{filepath},  $filepath, 'filepath'  );
              is( $serialized->{command},   'load',    'command'   );
              is( $serialized->{directory}, $dir,      'directory' );

              like( $serialized->{contents}, qr/content/, 'contents' );

              done_testing();
          };


      };

done_testing();
