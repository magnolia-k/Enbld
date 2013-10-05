package Enbld::Definition::Apr;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;
    
    $self->SUPER::initialize;
    
    $self->{defined}{ArchiveName}       =   'apr';
    $self->{defined}{WebSite}           =   'http://apr.apache.org';
    $self->{defined}{VersionForm}       =   '\d\.\d\.\d{1,2}';
    $self->{defined}{Extension}         =   'tar.gz';
    $self->{defined}{DownloadSite}      =   'http://archive.apache.org/dist/apr/';

    $self->{defined}{CommandConfigure}  =   './configure';
    $self->{defined}{CommandMake}       =   'make';
    $self->{defined}{CommandTest}       =   undef;
    $self->{defined}{CommandInstall}    =   'make install';

    return $self;
}

1;

