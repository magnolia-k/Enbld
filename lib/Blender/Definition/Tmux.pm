package Blender::Definition::Tmux;

use 5.012;
use warnings;

use parent qw/Blender::Definition/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{IndexSite}         =
        'http://sourceforge.net/projects/tmux/files/tmux/';
    $self->{defined}{AdditionalArgument}   =  \&set_argument;
    $self->{defined}{ArchiveName}       =   'tmux';
    $self->{defined}{WebSite}           =   'http://tmux.sourceforge.net';
    $self->{defined}{VersionForm}       =   '\d\.\d';
    $self->{defined}{Extension}         =   'tar.gz';
    $self->{defined}{Dependencies}      =   [ 'pkgconfig', 'libevent' ];
    $self->{defined}{DownloadSite}      =
        'http://sourceforge.net/projects/tmux/files/tmux/';

    $self->{defined}{IndexParserForm}   =   \&set_index_parser_form;
    $self->{defined}{URL}               =   \&set_URL;

    $self->{defined}{CommandConfigure}  =   'sh configure';
    $self->{defined}{CommandMake}       =   'make';
    $self->{defined}{CommandTest}       =   'make test';
    $self->{defined}{CommandInstall}    =   'make install';

    return $self;
}

sub set_argument {

    require Blender::Home;
    require Blender::Feature;

    my $path = Blender::Feature->is_deploy_mode ?
        File::Spec->catdir( Blender::Home->deploy_path, 'lib', 'pkgconfig' ) :
        File::Spec->catdir( Blender::Home->home, 'lib', 'pkgconfig' );

    my $env = 'PKG_CONFIG_PATH=' . $path;

    return $env;
}

sub set_index_parser_form {
    my $attributes = shift;

    my $index_form = quotemeta( $attributes->ArchiveName ) . '-' .
                $attributes->VersionForm;

    my $index_parser_form = '<a href="/projects/tmux/files/tmux/' .
        $index_form . '/stats/timeline"';

    return $index_parser_form;
}

sub set_URL {
    my $attributes = shift;

    my $site = 'http://sourceforge.net/projects/tmux/files/tmux/';

    my $dir  = $attributes->ArchiveName . '-' . $attributes->Version;
    my $file = $attributes->ArchiveName . '-' . $attributes->Version .
        '.' . $attributes->Extension;

    my $url = $site . $dir . '/' . $file . '/download';

    return $url;
}

1;
