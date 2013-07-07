package Blender::Target::AttributeCollector;

use 5.012;
use warnings;

use Carp;

sub new {
    my $class = shift;

    return bless {}, $class;
}

sub add {
    my ( $self, $name, $param ) = @_;

    if ( $self->{$name} ) {
        require Blender::Exception;
        croak( Blender::Exception->new( $name . " is already added" ) );
    }

    require Blender::Target::Attribute;
    $self->{$name} = Blender::Target::Attribute->new( $name, $param );
    $self->{$name}->link_to_collector( $self );

    return $self;
}

sub AUTOLOAD {
    my $self = shift;

    my $method = our $AUTOLOAD;
    $method =~ s/.*:://;

    return $self->{$method}->to_value if ( exists $self->{$method} );

    require Blender::Exception;
    croak( Blender::Exception->new( "'$method' is invalid method" ) );
}

1;
