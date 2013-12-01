package Enbld::Definition::Scala;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{ArchiveName}       =   'scala';
    $self->{defined}{WebSite}           =   'http://www.scala-lang.org';
    $self->{defined}{VersionForm}       =   '\d\.\d{1,2}\.\d';
    $self->{defined}{Extension}         =   'tgz';
    $self->{defined}{DownloadSite}      =   'http://www.scala-lang.org/files/archive/';

    $self->{defined}{CopyFiles}         =
        [ 'bin', 'examples', 'man', 'src', 'doc', 'lib', 'misc' ];

    $self->{defined}{CommandConfigure}  =   undef;
    $self->{defined}{CommandMake}       =   undef;
    $self->{defined}{CommandTest}       =   undef;
    $self->{defined}{CommandInstall}    =   undef;

    return $self;
}

1;
