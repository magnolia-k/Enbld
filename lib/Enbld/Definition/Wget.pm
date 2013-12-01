package Enbld::Definition::Wget;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;
    
    $self->SUPER::initialize;
    
    $self->{defined}{WebSite}           =   'http://www.gnu.org/software/wget/';

    $self->{defined}{Dependencies}      =   [ 'libidn' ];

    $self->{defined}{DownloadSite}      =   'http://ftp.gnu.org/gnu/wget/';

    $self->{defined}{ArchiveName}       =   'wget';
    $self->{defined}{VersionForm}       =   '\d{1,2}\.\d{1,2}(\.\d{1,2})?';
    
    $self->{defined}{AdditionalArgument}=   \&set_argument;

    return $self;
}

sub set_argument {
    my $attributes = shift;
    
    require Enbld::Home;
    my $to_install = Enbld::Home->library;

    my $argument = "--with-ssl=openssl --enable-iri --with-libidn=$to_install";

    $argument .= ' ' . 'PERL=/usr/bin/perl POD2MAN=/usr/bin/pod2man';

    return $argument;
}

1;

