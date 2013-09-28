package Enbld::Definition::Tree;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{ArchiveName}       =   'tree';
    $self->{defined}{WebSite}           =
        'http://mama.indstate.edu/users/ice/tree/';
    $self->{defined}{AdditionalArgument} = \&set_args;
    $self->{defined}{VersionForm}       =   '1\.\d\.\d';
    $self->{defined}{Extension}         =   'tgz';
    $self->{defined}{DownloadSite}      =
        'http://mama.indstate.edu/users/ice/tree/src/';

    $self->{defined}{Prefix}            =   'prefix=';

    $self->{defined}{CommandConfigure}  =   undef;
    $self->{defined}{CommandMake}       =   'make';
    $self->{defined}{CommandTest}       =   undef;
    $self->{defined}{CommandInstall}    =   'make install';

    return $self;
}

sub set_args {

    my $args = 'CFLAGS="-O2 -Wall -fomit-frame-pointer -no-cpp-precomp"' .
        ' '.  'LDFLAGS=' . ' ' .
        'OBJS="tree.o unix.o html.o xml.o hash.o color.o strverscmp.o"';

    return $args;
}

1;
