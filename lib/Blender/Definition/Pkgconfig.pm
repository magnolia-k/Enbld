package Blender::Definition::Pkgconfig;

use 5.012;
use warnings;

use parent qw/Blender::Definition/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{ArchiveName}       =   'pkg-config';
    $self->{defined}{WebSite}           =
        'http://www.freedesktop.org/wiki/Software/pkg-config/';
    $self->{defined}{VersionForm}       =   '\d\.\d{1,2}(?:\.\d)?';
    $self->{defined}{Extension}         =   'tar.gz';
    $self->{defined}{DownloadSite}      =
        'http://pkgconfig.freedesktop.org/releases/';

    $self->{defined}{CommandConfigure}  =   './configure --with-internal-glib';
    $self->{defined}{CommandMake}       =   'make';
    $self->{defined}{CommandTest}       =   'make check';
    $self->{defined}{CommandInstall}    =   'make install';

    return $self;
}

1;
