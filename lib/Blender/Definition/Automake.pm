package Blender::Definition::Automake;

use 5.012;
use warnings;

use parent qw/Blender::Definition/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{ArchiveName}       =   'automake';
    $self->{defined}{WebSite}           =   'http://www.gnu.org/software/automake/';
    $self->{defined}{VersionForm}       =   '1\.\d{1,2}(\.\d{1,2})?';
    $self->{defined}{Extension}         =   'tar.gz';
    $self->{defined}{DownloadSite}      =   'http://ftp.gnu.org/gnu/automake/';

    $self->{defined}{Dependencies}      =   [ 'autoconf' ];

    $self->{defined}{CommandConfigure}  =   './configure';
    $self->{defined}{CommandMake}       =   'make';
    $self->{defined}{CommandTest}       =   'make check';
    $self->{defined}{CommandInstall}    =   'make install';

    return $self;
}

1;
