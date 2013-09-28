package Enbld::Definition::Libevent;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{ArchiveName}       =   'libevent';
    $self->{defined}{WebSite}           =   'http://libevent.org';
    $self->{defined}{VersionForm}       =   '\d\.\d\.\d{1,2}';
    $self->{defined}{Extension}         =   'tar.gz';
    $self->{defined}{IndexSite}         =
        'http://libevent.org/old-releases.html';
    $self->{defined}{DownloadSite}      =
        'https://github.com/downloads/libevent/libevent/';
    $self->{defined}{IndexParserForm}   =   \&set_index_parser_form;
    $self->{defined}{Filename}          =   \&set_filename;

    $self->{defined}{CommandConfigure}  =   './configure';
    $self->{defined}{CommandMake}       =   'make';
    $self->{defined}{CommandTest}       =   'make verify';
    $self->{defined}{CommandInstall}    =   'make install';

    return $self;
}

sub set_filename {
    my $attributes = shift;

    my $filename = $attributes->ArchiveName . '-' . $attributes->Version .
        '-stable.' . $attributes->Extension;

    return $filename;
}

sub set_index_parser_form {
    my $attributes = shift;

    my $parser = 'href="' .quotemeta( $attributes->DownloadSite ). 
        quotemeta( $attributes->ArchiveName ). '-' . $attributes->VersionForm .
        '-stable.' . quotemeta( $attributes->Extension ) . '">';

    return $parser;
}

1;
