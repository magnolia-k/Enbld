package Enbld::Definition::Groff;

use 5.012;
use warnings;

use parent qw/Enbld::Definition/;

sub initialize {
    my $self = shift;

    $self->SUPER::initialize;

    $self->{defined}{ArchiveName}      = 'groff';
    $self->{defined}{WebSite}          = 'http://www.gnu.org/software/groff/';
    $self->{defined}{VersionForm}      = '\d\.\d{1,2}(\.\d)?';
    $self->{defined}{DownloadSite}     = 'http://ftp.gnu.org/gnu/groff/';

    $self->{defined}{CommandConfigure} = 'LANG=C;./configure';
    $self->{defined}{CommandMake}      = 'LANG=C;make';
    $self->{defined}{CommandTest}      = 'LANG=C;make check';
    $self->{defined}{CommandInstall}   = 'LANG=C;make install';

    return $self;
}

1;

=pod

=head1 NAME

Enbld::Definition::Groff - definition module for GNU Troff

=head1 SEE ALSO

L<GNU Troff|http://www.gnu.org/software/groff/>
L<Enbld::Definition>

=head1 COPYRIGHT

copyright 2013- Magnolia C<< <magnolia.k@me.com> >>.

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
