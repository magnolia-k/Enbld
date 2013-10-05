package Enbld::Definition::Aprutil;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;
    
    $self->SUPER::initialize;
    
    $self->{defined}{ArchiveName}       =   'apr-util';
    $self->{defined}{WebSite}           =   'http://apr.apache.org';
    $self->{defined}{VersionForm}       =   '\d\.\d\.\d{1,2}';
    $self->{defined}{Extension}         =   'tar.gz';
    $self->{defined}{DownloadSite}      =   'http://archive.apache.org/dist/apr/';

    $self->{defined}{Dependencies}      =   [ 'apr' ];

    $self->{defined}{AdditionalArgument}=   \&set_argument;

    $self->{defined}{CommandConfigure}  =   './configure';
    $self->{defined}{CommandMake}       =   'make';
    $self->{defined}{CommandTest}       =   undef;
    $self->{defined}{CommandInstall}    =   'make install';

    return $self;
}

sub set_argument {
    my $attributes = shift;

    require Enbld::Home;
    my $to_install = Enbld::Home->library;

    my $argument = "--with-apr=$to_install";

    return $argument;
}

1;

