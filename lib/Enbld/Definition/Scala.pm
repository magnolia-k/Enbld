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

    $self->{defined}{CommandConfigure}  =   '';
    $self->{defined}{CommandMake}       =   '';
    $self->{defined}{CommandTest}       =   '';
    $self->{defined}{CommandInstall}    =   '';

    return $self;
}

1;
