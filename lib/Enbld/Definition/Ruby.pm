package Enbld::Definition::Ruby;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

require Enbld::Home;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{ArchiveName}    = 'ruby';
    $self->{defined}{WebSite}        = 'https://www.ruby-lang.org';
    $self->{defined}{VersionForm}    = '\d\.\d\.\d-p\d{1,3}';
    $self->{defined}{Dependencies}   = \&set_Dependencies;
    $self->{defined}{DownloadSite}   = 'http://cache.ruby-lang.org/pub/ruby/';

    $self->{defined}{AdditionalArgument} = \&set_argument;
    $self->{defined}{SortedVersionList}  = \&set_sorted_version_list;

    return $self;
}

sub set_Dependencies {
    return $^O eq 'darwin' ? [ 'openssl' ] : undef;
}

sub set_sorted_version_list {
    my $attributes = shift;

    my @sorted = sort { $a cmp $b } @{ $attributes->VersionList };

    return \@sorted;
}

sub set_argument {
    return $^O eq 'darwin' ?
        "--with-openssl-dir=" . Enbld::Home->library :
        undef;
}

1;
