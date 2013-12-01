package Enbld::Definition::Libidn;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{WebSite}      = 'http://www.gnu.org/software/libidn/';
    $self->{defined}{DownloadSite} = 'http://ftp.gnu.org/gnu/libidn/';

    $self->{defined}{ArchiveName}  = 'libidn';
    $self->{defined}{VersionForm}  = '1\.\d{1,2}';

    return $self;
}


1;
