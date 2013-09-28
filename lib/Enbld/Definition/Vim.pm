package Enbld::Definition::Vim;

use 5.012;
use warnings;

use version;

use parent qw/Enbld::Definition/;

use List::Util qw/first max/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{ArchiveName}       =   'vim';
    $self->{defined}{WebSite}           =   'http://www.vim.org';
    $self->{defined}{VersionForm}       =   '7\.\d(?:\.\d{3,4})?';
    $self->{defined}{Extension}         =   'tar.bz2';
    $self->{defined}{DownloadSite}      =   'http://ftp.vim.org/pub/vim/unix/';

    $self->{defined}{AdditionalArgument} =
        '--enable-multibyte --with-features=big';

    $self->{defined}{VersionList}       =   \&set_versionlist;

    $self->{defined}{Filename}          =   \&set_filename;
    $self->{defined}{Version}           =   \&set_version;
    $self->{defined}{PatchFiles}        =   \&set_patchfiles;

    $self->{defined}{CommandConfigure}  =   'LANG=C;./configure';
    $self->{defined}{CommandMake}       =   'LANG=C;make';
    $self->{defined}{CommandTest}       =   'LANG=C;make test';
    $self->{defined}{CommandInstall}    =   'LANG=C;make install';

    return $self;
}

sub set_filename {
    my $attributes = shift;

    my $archive_name = $attributes->ArchiveName;
    my $major = _search_major_version( $attributes );
    my $extension = $attributes->Extension;
    
    my $filename = $archive_name . '-' . $major . '.' . $extension;

    return $filename;
}

sub set_version {
    my $attributes = shift;

    my $major       = _search_major_version( $attributes );
    my $patchfiles  = _search_patchfiles( $attributes, $major );

    return $major unless ( $patchfiles );

    return $patchfiles->[-1];
}

sub set_patchfiles {
    my $attributes = shift;

    my $major       = _search_major_version( $attributes );
    my $patchfiles  = _search_patchfiles( $attributes, $major );

    return unless ( $patchfiles );

    my $url = 'http://ftp.vim.org/pub/vim/patches/';

    my $list;
    foreach my $patch ( @{ $patchfiles } ) {
        next if ( $attributes->VersionCondition ne 'latest' &&
                version->declare( $attributes->VersionCondition ) <
                version->declare( $patch ) );

        push @{ $list }, $url . $major . '/'. $patch;
    }

    return $list;
}

sub _search_major_version {
    my $attributes = shift;

    require Enbld::HTTP;
    my $html = Enbld::HTTP->new( $attributes->IndexSite )->get_html;
    my $list = $html->parse_version( '<a href="vim-7\.\d\.tar\.bz2">', '7\.\d');

    unless ( @{ $list } ) {
        require Enbld::Error;
        die( Enbld::Error->new( "Can't get version list." ));
    }

    my @sorted = sort {
        version->declare( $a ) cmp version->declare( $b )
    } @{ $list };

    return $sorted[-1] if ( $attributes->VersionCondition eq 'latest' );

    my $major = substr( $attributes->VersionCondition, 0, 3 );

    return $major if ( grep { $major eq $_ } @{ $list } );

    require Enbld::Error;
    die( Enbld::Error->new(
                "Invalid Version Condition:$attributes->VersionCondition, ".
                "please check install condition"
                ));
}

sub _search_patchfiles {
    my $attributes = shift;
    my $major = shift;

    my $url = 'http://ftp.vim.org/pub/vim/patches/';
    require Enbld::HTTP;
    my $html_list = Enbld::HTTP->new( $url )->get_html;
    my $dir_list = $html_list->parse_version( '<a href="7\.\d/">', $major );

    return unless ( $dir_list );

    my $html_patchfiles = Enbld::HTTP->new( $url . $major )->get_html;
    my $patchfiles = $html_patchfiles->parse_version(
            '<a href="7\.\d\.\d{3,4}">',
            $attributes->VersionForm
            );

    return unless ( @{ $patchfiles } );

    my @sorted = sort {
        version->declare( $a ) cmp version->declare( $b )
    } @{ $patchfiles };

    return \@sorted;
}

sub set_versionlist {
    my $attributes = shift;

    my $versionlist;

    # search major version number
    require Enbld::HTTP;
    my $html = Enbld::HTTP->new( $attributes->IndexSite )->get_html;
    my $list = $html->parse_version( '<a href="vim-7\.\d\.tar\.bz2">', '7\.\d');

    push @{ $versionlist }, @{ $list };

    # search patch number
    for my $ver ( @{ $list } ) {
        my $patchlist = _search_patchfiles( $attributes, $ver );
        push @{ $versionlist }, @{ $patchlist };
    }

    return $versionlist;
}

1;
