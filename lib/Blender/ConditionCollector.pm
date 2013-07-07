package Blender::ConditionCollector;

use 5.012;
use warnings;

use Carp;

our %collection;

sub destroy {
    # method for only test code.
    undef %collection;
}

sub search {
    my ( $pkg, $name ) = @_;

    return unless $name;

    return $collection{$name} if ( exists $collection{$name} );

    return;
}

sub add {
    my ( $pkg, $condition ) = @_;

    if ( ! $condition ) {
        my $err = "add method requires condition object";
        require Blender::Exception;
        croak( Blender::Exception->new( $err ));
    }

    if ( exists $collection{$condition->name} ) {
        my $err = $condition->name . " is already added";
        require Blender::Exception;
        croak( Blender::Exception->new( $err ));
    }

    $collection{$condition->name} = $condition;

    return $condition->name;
}

1;
