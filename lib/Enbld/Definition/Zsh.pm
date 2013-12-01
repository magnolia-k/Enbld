package Enbld::Definition::Zsh;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;
    
    $self->SUPER::initialize;
    
    $self->{defined}{ArchiveName}     = 'zsh';
    $self->{defined}{WebSite}         = 'http://www.zsh.org';
    $self->{defined}{VersionForm}     = '\d\.\d\.\d';
    $self->{defined}{DownloadSite}    = 'http://sourceforge.net/projects/zsh/files/zsh/';

    $self->{defined}{IndexParserForm} = \&set_index_parser_form;
    $self->{defined}{URL}             = \&set_URL;

    return $self;
}

sub set_index_parser_form {
    my $attributes = shift;

    my $index_parser_form = '<a href="/projects/zsh/files/zsh/' .
        $attributes->VersionForm .'/"';

    return $index_parser_form;
}

sub set_URL {
    my $attributes = shift;

    my $site = 'http://sourceforge.net/projects/zsh/files/zsh/';

    my $dir  = $attributes->Version;
    my $file = $attributes->ArchiveName . '-' . $attributes->Version .
        '.' . $attributes->Extension;

    my $url = $site . $dir . '/' . $file . '/download';

    return $url;
}

1;
