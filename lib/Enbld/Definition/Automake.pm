package Enbld::Definition::Automake;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{WebSite}      = 'http://www.gnu.org/software/automake/';
    $self->{defined}{DownloadSite} = 'http://ftp.gnu.org/gnu/automake/';

    $self->{defined}{ArchiveName}  = 'automake';
    $self->{defined}{VersionForm}  = '1\.\d{1,2}(\.\d{1,2})?';

    $self->{defined}{Dependencies} = [ 'autoconf' ];

    return $self;
}

1;
