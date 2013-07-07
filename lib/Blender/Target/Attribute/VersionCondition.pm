package Blender::Target::Attribute::VersionCondition;

use 5.012;
use warnings;

use Carp;

use parent qw/Blender::Target::AttributeExtension::Word/;

sub initialize {
    my ( $self, $param ) = @_;

    if ( ! defined $param ) {
        $self->{value} = 'latest';
        $self->{is_evaluated}++;

        return $self;
    }

    if ( $param ) {
        $self->SUPER::initialize( $param );
        return $self;
    }

    require Blender::Exception;
    my $err = "Attribute 'VersionCondition' isn't defined";
    croak( Blender::Exception->new( $err ));
}

sub validate {
    my ( $self, $string ) = @_;

    $self->SUPER::validate( $string );

    return $string if ( $string eq 'latest' );

    my $allowed = $self->{attributes}->AllowedCondition;
    return $string if ( $allowed and ( $string eq $allowed ) );

    my $form = $self->{attributes}->VersionForm;
    return $string if ( $string =~ /^$form$/ );

    my $err = "Invalid Version Condition:$string," .
        " please check install condition";
    require Blender::Error;
    die( Blender::Error->new( $err ));
}

1;
