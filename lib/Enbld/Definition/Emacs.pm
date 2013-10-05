package Enbld::Definition::Emacs;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;
    
    $self->SUPER::initialize;
    
    $self->{defined}{ArchiveName}       =   'emacs';
    $self->{defined}{WebSite}           =   'http://www.gnu.org/software/emacs/';
    $self->{defined}{VersionForm}       =   '2\d\.\d';
    $self->{defined}{Extension}         =   'tar.gz';
    $self->{defined}{DownloadSite}      =   'http://ftp.gnu.org/gnu/emacs/';

    $self->{defined}{AdditionalArgument} =  '--without-x --without-dbus';

    $self->{defined}{CommandConfigure}  =   './configure';
    $self->{defined}{CommandMake}       =   'make';
    $self->{defined}{CommandTest}       =   'make check';
    $self->{defined}{CommandInstall}    =   'make install';

    return $self;
}

1;

