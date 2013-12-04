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

=pod

=head1 NAME

Enbld::Definition::Ruby - definition module for Ruby Programming Language

=head1 SEE ALSO

L<Ruby Programming Language|https://www.ruby-lang.org>
L<Enbld::Definition>

=head1 COPYRIGHT

copyright 2013- Magnolia C<< <magnolia.k@me.com> >>.

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
