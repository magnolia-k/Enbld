package Blender::Definition::Groff;

use 5.012;
use warnings;

use parent qw/Blender::Definition/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{ArchiveName}       =   'groff';
    $self->{defined}{WebSite}           =   'http://www.gnu.org/software/groff/';
    $self->{defined}{VersionForm}       =   '\d\.\d{1,2}(\.\d)?';
    $self->{defined}{Extension}         =   'tar.gz';
    $self->{defined}{DownloadSite}      =   'http://ftp.gnu.org/gnu/groff/';

    $self->{defined}{CommandConfigure}  =   'LANG=C;./configure';
    $self->{defined}{CommandMake}       =   'LANG=C;make';
    $self->{defined}{CommandTest}       =   'LANG=C;make check';
    $self->{defined}{CommandInstall}    =   'LANG=C;make install';

    return $self;
}

1;
