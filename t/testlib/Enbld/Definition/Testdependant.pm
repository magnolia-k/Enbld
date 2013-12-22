package Enbld::Definition::Testdependant;

use strict;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{ArchiveName}       =   'TestApp';
    $self->{defined}{WebSite}           =   'http://www.example.com/';
    $self->{defined}{DistName}          =   'TestDependant';
    $self->{defined}{VersionForm}       =   '\d\.\d';
    $self->{defined}{Extension}         =   'tar.gz';
    $self->{defined}{Dependencies}      =   [ 'testapp' ],
    $self->{defined}{DownloadSite}      =   'http://www.example.com/';

    $self->{defined}{CommandConfigure}  =   './configure';
    $self->{defined}{CommandMake}       =   'make';
    $self->{defined}{CommandTest}       =   'make test';
    $self->{defined}{CommandInstall}    =   'make install';

    return $self;
}

1;
