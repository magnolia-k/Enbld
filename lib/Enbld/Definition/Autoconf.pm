package Enbld::Definition::Autoconf;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{ArchiveName}       =   'autoconf';
    $self->{defined}{WebSite}           =   'http://www.gnu.org/software/autoconf/';
    $self->{defined}{VersionForm}       =   '2\.\d{1,2}';
    $self->{defined}{Extension}         =   'tar.gz';
    $self->{defined}{DownloadSite}      =   'http://ftp.gnu.org/gnu/autoconf/';

    $self->{defined}{CommandConfigure}  =   './configure';
    $self->{defined}{CommandMake}       =   'make';
    $self->{defined}{CommandTest}       =   'make check';
    $self->{defined}{CommandInstall}    =   'make install';

    return $self;
}

1;
