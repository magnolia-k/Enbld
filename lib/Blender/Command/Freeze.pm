package Blender::Command::Freeze;

use 5.012;
use warnings;

use parent qw/Blender::Command/;

require Blender::ConfigCollector;
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
    say "blend '" . Blender::ConfigCollector->blend_name . "' => build {";
    say "";

    foreach my $name ( sort keys %{ Blender::ConfigCollector->collection } ) {
        my $config = Blender::ConfigCollector->search( $name );

        my $version = Blender::Feature->is_current_mode ?
            $config->enabled : $config->condition->version;

        my $make_test = $config->condition->make_test;

        say ' ' x 4 . "target '" . $name . "' => define {";
        say ' ' x 8 . "version '" . $version . "';";
        say ' ' x 8 . "make_test '" . $make_test . "';" if $make_test;
        say ' ' x 4 . "};";
        say "";
    }

    say "};";

    return $self;
}

1;

__DATA__
#!/usr/bin/perl

use 5.012;
use warnings;

