package Enbld::Definition::Mysql;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

use version;

require Enbld::HTTP;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{IndexSite}         =
        'http://downloads.mysql.com/archives/community/';
    $self->{defined}{ArchiveName}       =   'mysql';
    $self->{defined}{WebSite}           =   'http://www.mysql.com';
    $self->{defined}{VersionForm}       =   '5\.\d\.\d{1,2}';
    $self->{defined}{Extension}         =   'tar.gz';
    $self->{defined}{DownloadSite}      =   'http://www.mysql.com/';

    $self->{defined}{Dependencies}      =   [ 'cmake' ];

    $self->{defined}{VersionList}       =   \&set_versionlist;

    $self->{defined}{URL}               =   \&set_url;

    $self->{defined}{Prefix}            =   '-DCMAKE_INSTALL_PREFIX=';

    $self->{defined}{CommandConfigure}  =   'cmake .';
    $self->{defined}{CommandMake}       =   'make';
    $self->{defined}{CommandTest}       =   'make test';
    $self->{defined}{CommandInstall}    =   'make install';

    return $self;
}

sub set_versionlist {
    my $attributes = shift;

    my $indexsite_latest = 'http://dev.mysql.com/downloads/';
    my $latest_html = Enbld::HTTP->get_html( $indexsite_latest );
    my $latest = $latest_html->parse_version(
            'Current Generally Available Release: '. $attributes->VersionForm,
            $attributes->VersionForm,
            );

    my @versionlist;
    push @versionlist, @{ $latest }; 

    push @versionlist, @{ archived_versions( $attributes ) };

    return \@versionlist;
}

sub archived_versions {
    my $attributes = shift;

    my $html = Enbld::HTTP->get_html( $attributes->IndexSite );
    my $list =
        $html->parse_version(
                quotemeta( '<option label="' ) . $attributes->VersionForm . '"',
                $attributes->VersionForm
                );

    return $list;
}

sub set_url {
    my $attributes = shift;

    my $list = $attributes->VersionList;

    my @versions = sort {
        version->declare( $a ) cmp version->declare( $b )
    } @{ $list }; 

    my $major;
    if ( $attributes->Version =~ /(5\.\d)\.\d{1,2}/ ) {
        $major = $1;
    }

    my $url;
    if ( $attributes->Version eq $versions[-1] ) {

        $url = 'http://dev.mysql.com/get/Downloads/MySQL-' . $major .
            '/mysql-' . $attributes->Version .
            '.tar.gz/from/http://cdn.mysql.com/';

    } else {
        $url = 'http://downloads.mysql.com/archives/mysql-' . $major . 
           '/mysql-' . $attributes->Version . '.tar.gz';
    }

    return $url;
}

1;
