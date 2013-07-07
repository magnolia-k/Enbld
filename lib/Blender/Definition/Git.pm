package Blender::Definition::Git;

use 5.012;
use warnings;

use parent qw/Blender::Definition/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{IndexSite}         =
        'http://code.google.com/p/git-core/downloads/list';
    $self->{defined}{ArchiveName}       =   'git';
    $self->{defined}{WebSite}           =   'http://git-scm.com';
    $self->{defined}{VersionForm}       =   '1\.\d\.\d{1,2}(\.\d{1,2})?';
    $self->{defined}{Extension}         =   'tar.gz';
    $self->{defined}{DownloadSite}      =
        'http://git-core.googlecode.com/files/';

    $self->{defined}{IndexParserForm}   =   \&set_index_parser_form;

    $self->{defined}{CommandConfigure}  =   'sh configure';
    $self->{defined}{CommandMake}       =   'make';
    $self->{defined}{CommandTest}       =   'make test';
    $self->{defined}{CommandInstall}    =   'make install';

    return $self;
}

sub set_index_parser_form {
    my $attributes = shift;

    my $filename_form = quotemeta( $attributes->ArchiveName ) . '-' .
                $attributes->VersionForm . '\.' . 
                quotemeta( $attributes->Extension );

    my $index_parser_form = 'name=' . $filename_form . '&amp';

    return $index_parser_form;
}

1;
