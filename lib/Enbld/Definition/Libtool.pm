package Enbld::Definition::Libtool;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{WebSite}      = 'http://www.gnu.org/software/libtool/';

    $self->{defined}{DownloadSite} = 'http://ftp.gnu.org/gnu/libtool/';
    $self->{defined}{ArchiveName}  = 'libtool';
    $self->{defined}{VersionForm}  = '\d\.\d\.\d{1,2}';

    return $self;
}


1;
