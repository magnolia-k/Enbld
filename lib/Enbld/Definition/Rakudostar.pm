package Enbld::Definition::Rakudostar;

use 5.012;
use warnings;

use version;

use parent qw/Enbld::Definition/;

require Enbld::Feature;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{ArchiveName}  = 'rakudo-star';
    $self->{defined}{WebSite}      = 'http://rakudo.org';
    $self->{defined}{VersionForm}  = '\d{4}\.\d{2}';
    $self->{defined}{DownloadSite} = 'http://rakudo.org/downloads/star/';

    $self->{defined}{CommandConfigure} = 'perl Configure.pl --gen-parrot';
    $self->{defined}{CommandMake}      = 'make';
    $self->{defined}{CommandTest}      = 'make rakudo-test';
    $self->{defined}{CommandInstall}   = 'make install';

    return $self;
}

1;
