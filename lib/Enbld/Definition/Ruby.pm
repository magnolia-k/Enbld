package Enbld::Definition::Ruby;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{ArchiveName}       =   'ruby';
    $self->{defined}{WebSite}           =   'https://www.ruby-lang.org';
    $self->{defined}{VersionForm}       =   '\d\.\d\.\d-p\d{1,3}';
    $self->{defined}{Extension}         =   'tar.gz';
    $self->{defined}{Dependencies}      =   \&set_Dependencies;
    $self->{defined}{DownloadSite}      =   'http://cache.ruby-lang.org/pub/ruby/';

    $self->{defined}{AdditionalArgument}=   \&set_argument;
    $self->{defined}{SortedVersionList} =   \&set_sorted_version_list;

    $self->{defined}{CommandConfigure}  =   './configure';
    $self->{defined}{CommandMake}       =   'make';
    $self->{defined}{CommandTest}       =   'make test';
    $self->{defined}{CommandInstall}    =   'make install';

    return $self;
}

sub set_Dependencies {
    my $attributes = shift;

    return $^O eq 'darwin' ? [ 'openssl' ] : undef;
}

sub set_sorted_version_list {
    my $attributes = shift;

    my $list = $attributes->VersionList;

    my @sorted = sort { $a cmp $b } @{ $list };

    return \@sorted;
}

sub set_argument {
    my $attributes = shift;

    require Enbld::Home;
    my $to_install = Enbld::Home->library;

    my $argument = "--with-openssl-dir=$to_install";

    return $argument;
}

1;
