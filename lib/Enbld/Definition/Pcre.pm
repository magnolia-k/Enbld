package Enbld::Definition::Pcre;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{IndexSite}         =
        'http://sourceforge.net/projects/pcre/files/pcre/';
 
    $self->{defined}{AdditionalArgument}   =  \&set_argument;
    $self->{defined}{ArchiveName}       =   'pcre';
    $self->{defined}{WebSite}           =   'http://www.pcre.org';
    $self->{defined}{VersionForm}       =   '\d\.\d{1,2}';
    $self->{defined}{DownloadSite}      =
        'http://sourceforge.net/projects/pcre/files/pcre/';

    $self->{defined}{IndexParserForm}   =   \&set_index_parser_form;
    $self->{defined}{URL}               =   \&set_URL;

    return $self;
}

sub set_argument {
    my $args = '--enable-utf --enable-unicode-properties';

    return $args;
};

sub set_index_parser_form {
    my $attributes = shift;

    my $index_parser_form = '<a href="/projects/pcre/files/pcre/' .
        $attributes->VersionForm . '/stats/timeline"';

    return $index_parser_form;
}

sub set_URL {
    my $attributes = shift;

    my $site = 'http://sourceforge.net/projects/pcre/files/pcre/';

    my $dir  = $attributes->Version;
    my $file = $attributes->ArchiveName . '-' . $attributes->Version .
        '.' . $attributes->Extension;

    my $url = $site . $dir . '/' . $file . '/download';

    return $url;
}

1;
