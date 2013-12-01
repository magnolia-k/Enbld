package Enbld::Definition::Apr;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;
    
    $self->SUPER::initialize;
    
    $self->{defined}{WebSite}      = 'http://apr.apache.org';

    $self->{defined}{DownloadSite} = 'http://archive.apache.org/dist/apr/';

    $self->{defined}{ArchiveName}  = 'apr';
    $self->{defined}{VersionForm}  = '\d\.\d\.\d{1,2}';

    return $self;
}

1;

