package Enbld::Module::Perl;

use strict;
use warnings;

use parent qw/Enbld::Module/;

use File::Spec;

require Enbld::Home;
require Enbld::Feature;
require Enbld::Error;

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
