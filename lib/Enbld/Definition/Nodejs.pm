package Enbld::Definition::Nodejs;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{ArchiveName}       =   'node';
    $self->{defined}{WebSite}           =   'http://nodejs.org';
    $self->{defined}{VersionForm}       =   'v\d\.\d{1,2}\.\d{1,2}';
    $self->{defined}{Extension}         =   'tar.gz';
    $self->{defined}{DownloadSite}      =   'http://nodejs.org/dist/';

    $self->{defined}{VersionList}       =   \&set_versionlist;
    $self->{defined}{URL}               =   \&set_url;

    $self->{defined}{CommandConfigure}  =   './configure';
    $self->{defined}{CommandMake}       =   'make';
    $self->{defined}{CommandTest}       =   'make test';
    $self->{defined}{CommandInstall}    =   'make install';

    return $self;
}

sub set_versionlist {
    my $attributes = shift;

    require Enbld::HTTP;
    my $html = Enbld::HTTP->get_html( $attributes->IndexSite );

    my $list = $html->parse_version(
            quotemeta( '<a href="') .
            'v\d\.\d{1,2}\.\d{1,2}/' .
            quotemeta( '">' ),
            'v\d\.\d{1,2}\.\d{1,2}'
            );

    return $list;
}

sub set_url {
    my $attributes = shift;

    my $ver = $attributes->Version;

    my $filename = $attributes->Filename;
    my $url = $attributes->DownloadSite . $ver . '/' . $filename;

    return $url;
}

1;
