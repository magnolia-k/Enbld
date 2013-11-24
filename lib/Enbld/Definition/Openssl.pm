package Enbld::Definition::Openssl;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{ArchiveName}       =   'openssl';
    $self->{defined}{WebSite}           =   'http://www.openssl.org/';
    $self->{defined}{VersionForm}       =   '\d\.\d\.\d\w?';
    $self->{defined}{Extension}         =   'tar.gz';
    $self->{defined}{DownloadSite}      =   'http://www.openssl.org/source/';

    $self->{defined}{AdditionalArgument}=   \&set_argument;

    $self->{defined}{SortedVersionList} =   \&set_sorted_version_list;

    $self->{defined}{CommandConfigure}  =   \&set_commandconfigure;
    $self->{defined}{CommandMake}       =   'make';
    $self->{defined}{CommandTest}       =   'make test';
    $self->{defined}{CommandInstall}    =   'make install';

    return $self;
}

sub set_commandconfigure {
    return $^O eq 'darwin' ? './configure' : './config';
}

sub set_argument {
    return $^O eq 'darwin' ? 'darwin64-x86_64-cc' : undef;
}

sub set_sorted_version_list {
    my $attributes = shift;

    my $list = $attributes->VersionList;

    my @sorted = sort { $a cmp $b } @{ $list };

    return \@sorted;
}

1;
