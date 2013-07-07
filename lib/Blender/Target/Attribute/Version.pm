package Blender::Target::Attribute::Version;

use 5.012;
use warnings;

use version;
use Carp;

use parent qw/Blender::Target::AttributeExtension::Word/;

sub initialize {
    my ( $self, $param ) = @_;

    if ( ! defined $param ) {
        $self->{callback} = sub {
            my $attributes = shift;

            my $list = $attributes->VersionList;

            if ( $attributes->VersionCondition eq 'latest' ) {
                my @versions = sort {
                    version->declare( $a ) cmp version->declare( $b )
                } @{ $list };

                return $versions[-1];
            }


            if ( grep { $attributes->VersionCondition eq $_ } @{ $list} ) {
                return $attributes->VersionCondition;
            }

            my $err = "Invalid Version Condition:" .
                        $attributes->VersionCondition . ", ".
                        "please check install condition";
            require Blender::Error;
            croak( Blender::Error->new( $err ));
        };

        return $self;
    }

    if ( $param ) {
        $self->SUPER::initialize( $param );
        return $self;
    }

    require Blender::Exception;
    my $err = "Attribute 'Version' isn't defined";
    croak( Blender::Exception->new( $err )); 
}

sub validate {
    my ( $self, $string ) = @_;

    $self->SUPER::validate( $string );

    my $form = $self->{attributes}->VersionForm;
    unless ( $string =~ /^$form$/ ) {
        my $err = 'Attribute Version is NOT valid version string.';
        require Blender::Exception;
        croak( Blender::Exception->new( $err, $string ));
    }

    return $string;
}

1;
