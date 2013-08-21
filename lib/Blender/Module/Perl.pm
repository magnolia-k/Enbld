package Blender::Module::Perl;

use 5.012;
use warnings;

use parent qw/Blender::Module/;

use File::Spec;

require Blender::Home;
require Blender::Feature;
require Blender::Error;

sub initialize {
    my $self = shift;

    $self->{command} = File::Spec->catfile( $self->{path}, 'bin', 'cpan' );
}

sub module {
    my ( $self, $name, $version ) = @_;

    return $name;
}

sub install_command {
    my ( $self, $module ) = @_;

    my $cmd = q{yes '' | } . $self->{command} . ' ' . $module;

    return $cmd;
}

1;
