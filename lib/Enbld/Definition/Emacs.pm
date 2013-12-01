package Enbld::Definition::Emacs;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;
    
    $self->SUPER::initialize;
    
    $self->{defined}{WebSite}      =   'http://www.gnu.org/software/emacs/';

    $self->{defined}{DownloadSite} =   'http://ftp.gnu.org/gnu/emacs/';

    $self->{defined}{ArchiveName}  =   'emacs';
    $self->{defined}{VersionForm}  =   '2\d\.\d';

    $self->{defined}{AdditionalArgument} =  '--without-x --without-dbus';

    return $self;
}

1;

