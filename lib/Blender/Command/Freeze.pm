package Blender::Command::Freeze;

use 5.012;
use warnings;

use parent qw/Blender::Command/;

require Blender::App::Configuration;
require Blender::Error;
require Blender::Message;
require Blender::Feature;
require Blender::Home;

sub do {
    my $self = shift;

    $self->setup;

    my $str = do { local $/; <DATA> };

    print $str;

    my $home = $ENV{PERL_BLENDER_HOME} ? '$ENV{PERL_BLENDER_HOME}' :
        '$ENV{HOME}/blended';

    say 'use lib "' . $home . '/Blender-Declare/lib/perl5/";';
    say "";
    say 'use Blender::Declare;';
    say "";
    say "blend '" . Blender::App::Configuration->blendname . "' => build {";
    say "";

    foreach my $name ( sort keys %{ Blender::App::Configuration->config } ) {
        my $config = Blender::App::Configuration->search_config( $name );

        my $lines = $config->DSL;

        foreach my $line ( @{ $lines } ) {
            print '    ' . $line;
        }

        print "\n";
    }

    print "\n";

    foreach my $file ( sort keys %{ Blender::App::Configuration->rcfile } ) {
        my $rcfile = Blender::App::Configuration->search_rcfile( $file );

        my $lines = $rcfile->DSL;

        foreach my $line ( @{ $lines } ) {
            print '    ' . $line;
        }

        print "\n";
    }

    say "};";

    return $self;
}

1;

__DATA__
#!/usr/bin/perl

use 5.012;
use warnings;

