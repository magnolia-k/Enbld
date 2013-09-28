package Enbld::Definition::Hello;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{ArchiveName}       =   'hello';
    $self->{defined}{WebSite}           =   'http://www.gnu.org/software/hello/';
    $self->{defined}{VersionForm}       =   '\d\.\d';
    $self->{defined}{Extension}         =   'tar.gz';
    $self->{defined}{DownloadSite}      =   'http://ftp.gnu.org/gnu/hello/';

    $self->{defined}{CommandConfigure}  =   './configure';
    $self->{defined}{CommandMake}       =   'make';
    $self->{defined}{CommandTest}       =   'make check';
    $self->{defined}{CommandInstall}    =   'make install';

    return $self;
}

1;
