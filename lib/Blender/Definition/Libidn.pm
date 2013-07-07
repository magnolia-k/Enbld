package Blender::Definition::Libidn;

use 5.012;
use warnings;

use parent qw/Blender::Definition/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{ArchiveName}       =   'libidn';
    $self->{defined}{WebSite}           =   'http://www.gnu.org/software/libidn/';
    $self->{defined}{VersionForm}       =   '1\.\d{1,2}';
    $self->{defined}{Extension}         =   'tar.gz';
    $self->{defined}{DownloadSite}      =   'http://ftp.gnu.org/gnu/libidn/';

    $self->{defined}{CommandConfigure}  =   './configure';
    $self->{defined}{CommandMake}       =   'make';
    $self->{defined}{CommandTest}       =   'make check';
    $self->{defined}{CommandInstall}    =   'make install';

    return $self;
}


1;
