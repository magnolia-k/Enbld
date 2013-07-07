package Blender::Target::Attribute::VersionList;

use 5.012;
use warnings;

use Carp;

use parent qw/Blender::Target::AttributeExtension::Word/;

require Blender::Exception;

sub initialize {
    my ( $self, $param ) = @_;

    if ( ! defined $param ) {
        $self->{callback} = sub {
            my $attributes = shift;

            require Blender::HTTP;
            my $html = Blender::HTTP->new( $attributes->IndexSite )->get_html;
            my $list = $html->parse_version(
                    $attributes->IndexParserForm,
                    $attributes->VersionForm
                    );

            return $list;
        };

        return $self;
    };

    if ( $param ) {
        $self->SUPER::initialize( $param );
        return $self;
    }

    my $err = "Attribute 'VersionList' isn't defined";
    croak( Blender::Exception->new( $err ));
}

sub validate {
    my ( $self, $value ) = @_;

    unless ( ref( $value ) eq 'ARRAY' ) {
        my $type = ref( $self );
        $type =~ s/.*:://;

        my $err = "Attribute 'VersionList' isn't ARRAY reference";
        croak( Blender::Exception->new( $err, $value ));
    }

    if ( ! @{ $value } ) {
        my $err = "Attribute 'VersionList' is no version list";
        croak( Blender::Exception->new( $err ));
    }

    foreach my $string ( @{ $value } ) {
        $self->SUPER::validate( $string );
    }

    return $value;
}

sub to_value {
    my $self = shift;

    my $value = $self->evaluate;

    return [] if ( ! defined $value );

    $self->validate( $value );

    my @list = sort @{ $value};

    return \@list;
}

1;
