package Blender::Command::Available;

use 5.012;
use warnings;

use parent qw/Blender::Command/;

use File::Spec;
use autodie;

use Module::Load;
use Module::Load::Conditional qw/can_load/;

require Blender::Home;
require Blender::Definition;

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

        if ( can_load( modules => { $module => undef } ) ) {
            load $module;

            my $attributes = Blender::Definition->new( $output )->parse;
            my $line = $output . ' ' x 15;
            print substr( $line, 0, 15 );
            print $attributes->WebSite . "\n";
        }
   }

    return $self;
}

1;
