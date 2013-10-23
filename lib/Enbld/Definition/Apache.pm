package Enbld::Definition::Apache;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;
    
    $self->SUPER::initialize;
    
    $self->{defined}{ArchiveName}       =   'httpd';
    $self->{defined}{WebSite}           =   'http://httpd.apache.org';
    $self->{defined}{VersionForm}       =   '2\.\d\.\d{1,2}';
    $self->{defined}{Extension}         =   'tar.gz';
    $self->{defined}{DownloadSite}      =   'http://archive.apache.org/dist/httpd/';

    $self->{defined}{Dependencies}      =   [ 'pcre', 'libtool', 'apr', 'aprutil' ];

    $self->{defined}{AdditionalArgument}=   \&set_argument;

    $self->{defined}{CommandConfigure}  =   './configure CC=/usr/bin/cc CPP=/usr/bin/cpp';
    $self->{defined}{CommandMake}       =   'make';
    $self->{defined}{CommandTest}       =   undef;
    $self->{defined}{CommandInstall}    =   'make install';

    return $self;
}

sub set_argument {
    my $attributes = shift;

    require Enbld::Home;
    my $to_install = Enbld::Home->library;

    my $argument = "--with-pcre=$to_install --with-apr=$to_install --with-apr-util=$to_install";

    return $argument;
}

1;

