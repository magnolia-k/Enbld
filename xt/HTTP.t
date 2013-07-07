#!/usr/bin/perl

use 5.012;
use warnings;

use Test::More;

require_ok( 'Blender::HTTP' );

use File::Spec;
use File::Temp;

my $dir = File::Temp->newdir;

my $archivefile         = '01mailrc.txt.gz';
my $url_archivefile     = 'http://cpan.perl.org/authors/';
my $path_archivefile    = File::Spec->catfile( $dir, '01mailrc.txt.gz' );

my $url_site    = 'http://cpan.perl.org';
my $url_invalid = 'ftp://www.example.com';

eval { Blender::HTTP->new( $url_invalid ) };
like( $@, qr/ABORT:'$url_invalid' isn't valid URL string/, 'invalid URL' );

SKIP: {
          skip "Skip HTTP client test because none of test env.",
               8 unless ( $ENV{PERL_BLENDER_TEST} );

# download
          my $http_archivefile = Blender::HTTP->new( $url_archivefile );
          my $downloaded = $http_archivefile->download( $path_archivefile );
          ok( -e $downloaded, 'download file' );

          my @filestat_downloaded = stat $downloaded;

          my $twice = $http_archivefile->download( $path_archivefile );
          my @filestat_twice = stat $twice;
          is( $filestat_downloaded[9], $filestat_twice[9], 'no downloaded' );

          my $obj_archivefile =
              $http_archivefile->download_archivefile( $path_archivefile );

          isa_ok( $obj_archivefile, 'Blender::Archivefile' );

# get
          my $http_html = Blender::HTTP->new( $url_site );
          my $content = $http_html->get;
          like( $content, qr/html/, 'get html' );
          my $obj_html = $http_html->get_html;
          isa_ok( $obj_html, 'Blender::HTML' );

# conversion attribute string
          my $url_author = 'http://cpan.perl.org/authors/02authors.txt.gz';
          require Blender::Target::Attribute;
          my $authorfile = Blender::Target::Attribute->new( 'URL', $url_author);
          my $path_authorfile = File::Spec->catfile( $dir, '02authors.txt.gz' );

          my $http_authorfile = Blender::HTTP->new( $authorfile->to_value );
          my $authorfile_downloaded =
              $http_authorfile->download( $path_authorfile );
          ok( -e $authorfile_downloaded , 'download file by attribute obj' );
      };

done_testing();
