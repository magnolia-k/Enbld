package Blender::Definition::Wget;

use 5.012;
use warnings;

use parent qw/Blender::Definition/;

sub initialize {
    my $self = shift;
    
    $self->SUPER::initialize;
    
    $self->{defined}{ArchiveName}       =   'wget';
    $self->{defined}{WebSite}           =   'http://www.gnu.org/software/wget/';
    $self->{defined}{VersionForm}       =   '\d{1,2}\.\d{1,2}(\.\d{1,2})?';
    $self->{defined}{Extension}         =   'tar.gz';
    $self->{defined}{Dependencies}      =   [ 'libidn' ];
    $self->{defined}{DownloadSite}      =   'http://ftp.gnu.org/gnu/wget/';
    
    $self->{defined}{AdditionalArgument}=   \&set_argument;
    
    $self->{defined}{CommandConfigure}  =   './configure';
    $self->{defined}{CommandMake}       =   'make';
    $self->{defined}{CommandTest}       =   'make check';
    $self->{defined}{CommandInstall}    =   'make install';

    return $self;
}

sub set_argument {
    my $attributes = shift;
    
    require Blender::Home;
    my $to_install = Blender::Home->library;

    my $argument = "--with-ssl=openssl --enable-iri --with-libidn=$to_install";

    $argument .= ' ' . 'PERL=/usr/bin/perl POD2MAN=/usr/bin/pod2man';

    return $argument;
}

1;

