package Blender::Command::Available;

use 5.012;
use warnings;

use parent qw/Blender::Command/;

use File::Spec;
use autodie;

require Blender::Home;
require Blender::Definition;
require Blender::Require;

sub do {
    my $self = shift;

    Blender::Home->initialize;

    my $path = File::Spec->catdir(
            Blender::Home->home,
            'Blender-Declare',
            'lib',
            'perl5',
            'Blender',
            'Definition'
            );

    opendir( my $dh, $path );
    my @list = grep { !/^\./ } readdir $dh;
    closedir $dh;

    foreach my $name ( sort @list ) {
        $name =~ s/\.pm$//;
        my $output = lc( $name );

        my $module = 'Blender::Definition::' . $name;
        Blender::Require->try_require( $module );

        my $attributes = $module->new->parse;

        say $output . ' ' x 8 . $attributes->WebSite;
    }

    return $self;
}

1;
