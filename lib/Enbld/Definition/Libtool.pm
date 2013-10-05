package Enbld::Definition::Libtool;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{ArchiveName}       =   'libtool';
    $self->{defined}{WebSite}           =   'http://www.gnu.org/software/libtool/';
    $self->{defined}{VersionForm}       =   '\d\.\d\.\d{1,2}';
    $self->{defined}{Extension}         =   'tar.gz';
    $self->{defined}{DownloadSite}      =   'http://ftp.gnu.org/gnu/libtool/';

    $self->{defined}{CommandConfigure}  =   './configure';
    $self->{defined}{CommandMake}       =   'make';
    $self->{defined}{CommandTest}       =   'make check';
    $self->{defined}{CommandInstall}    =   'make install';

    return $self;
}


1;
