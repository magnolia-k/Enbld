package Blender::Definition::Nginx;

use 5.012;
use warnings;

use parent qw/Blender::Definition/;

use File::Spec;

sub initialize {
    my $self = shift;
    
    $self->SUPER::initialize;
    
    $self->{defined}{ArchiveName}       =   'nginx';
    $self->{defined}{WebSite}           =   'http://nginx.org';
    $self->{defined}{VersionForm}       =   '1\.\d\.\d{1,2}';
    $self->{defined}{Extension}         =   'tar.gz';
    $self->{defined}{DownloadSite}      =   'http://nginx.org/download/';
    
    $self->{defined}{AdditionalArgument}=   \&set_argument;
    
    $self->{defined}{CommandConfigure}  =   './configure';
    $self->{defined}{CommandMake}       =   'make';
    $self->{defined}{CommandTest}       =   undef;
    $self->{defined}{CommandInstall}    =   'make install';

    return $self;
}

sub set_argument {
    my $attributes = shift;

    require Blender::Definition;
    my $pcre = Blender::Definition->new( 'pcre' )->parse;
    $pcre->add( 'VersionCondition', 'latest' );

    require Blender::HTTP;
    my $http = Blender::HTTP->new( $pcre->URL );

    require Blender::Home;
    my $path = File::Spec->catfile( Blender::Home->dists, $pcre->Filename );
    my $archivefile = $http->download_archivefile( $path );
    my $build = $archivefile->extract( Blender::Home->build );

    my $argument = "--with-http_ssl_module --with-pcre=" . $build;

    return $argument;
}

1;

