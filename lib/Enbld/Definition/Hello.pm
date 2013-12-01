package Enbld::Definition::Hello;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{WebSite}      = 'http://www.gnu.org/software/hello/';

    $self->{defined}{DownloadSite} = 'http://ftp.gnu.org/gnu/hello/';
    $self->{defined}{ArchiveName}  = 'hello';
    $self->{defined}{VersionForm}  = '\d\.\d';

    return $self;
}

1;
