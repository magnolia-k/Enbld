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
        'http://downloads.mysql.com/archives.php';
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

    my $index_site = 'http://downloads.mysql.com/archives.php';

    my $major_html = Enbld::HTTP->get_html( $index_site );
    my $major_list = $major_html->parse_version(
            quotemeta( '<a href="archives.php?p=mysql-' ) .
            '5\.\d' .
            quotemeta( '">MySQL Database Server ' ) .
            '5\.\d' .
            quotemeta( '</a>' ),
            '5\.\d'
            );

    my @versionlist;
    my $revision_site = 'http://downloads.mysql.com/archives.php?p=mysql-';
    for my $major ( @{ $major_list } ) {
        my $revision_html = Enbld::HTTP->get_html( $revision_site . $major );
        my $revision_list = $revision_html->parse_version(
                quotemeta( '<a href="archives.php?p=mysql-' ) .
                '5\.\d' .
                quotemeta( '&v=' ) .
                $attributes->VersionForm .
                quotemeta( '">' ),
                $attributes->VersionForm,
                );

        push @versionlist, @{ $revision_list };
    }

    return \@versionlist;
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
