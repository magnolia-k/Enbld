package Blender::Condition;

use 5.012;
use warnings;

use Carp;
require Blender::Exception;
require Blender::Error;
        
sub new {
    my $class = shift;

    my $self = {
        name        =>  undef,
        version     =>  'latest',
        make_test   =>  undef,
        modules     =>  undef,
        @_,
    };

    bless $self, $class;

    $self->_validate;

    return $self;
}

sub _validate {
    my $self = shift;

    unless ( $self->{name} ) {
        my $err = "'Blender::Condition' requires name parameter.";
        croak( Blender::Exception->new( $err ) );
    }

    $self->_validate_modules;
}

sub _validate_modules {
    my $self = shift;

    return $self unless $self->{modules};

    if ( ref( $self->{modules} ) ne 'HASH' ) {
        die( Blender::Error->new( "condition 'modules' must be hash ref." ));
    }

    foreach my $name ( sort keys %{ $self->{modules} } ) {

        if ( ! defined( $self->{modules}{$name} ) ) {
            die( Blender::Error->new( "module's version isn't set." ));
        }

        if ( ref( $self->{modules}{$name} ) ) {
            die( Blender::Error->new( "module's version must be a scalar." ));
        }
    }

    return $self;
}

sub name {
    return $_[0]->{name};
}

sub version {
    return $_[0]->{version};
}

sub make_test {
    return $_[0]->{make_test};
}

sub set_make_test {
    my ( $self, $make_test ) = @_;
    $self->{make_test} = $make_test;

    return $self->{make_test};
}

sub modules {
    return $_[0]->{modules};
}

sub serialize {
    my $self = shift;

    my %serialized;
    foreach my $key ( sort keys %{ $self } ) {
        next if ( ! $self->{$key} );

        $serialized{$key} = $self->{$key};
    }

    return \%serialized;
}

sub serialize_without_name {
    my $self = shift;

    my %serialized;
    foreach my $key ( sort keys %{ $self } ) {
        next if $key eq 'name';
        next if ( ! $self->{$key} );

        $serialized{$key} = $self->{$key};
    }

    return \%serialized;
}

sub is_equal_to {
    my ( $self, $condition ) = @_;

    if ( ! $condition ) {
        my $err = "is_equal_to method requires Blender::Condition object.";
        croak( Blender::Exception->new( $err ));
    }

    if ( $self->{name} ne $condition->name ) {
        my $err = "is_equal_to method requires same target condition.";
        croak( Blender::Exception->new( $err ));
    }

    return unless ( _is_equal( $self->{version}, $condition->version ));
    return unless ( _is_equal( $self->{make_test}, $condition->make_test ));
    return unless ( _is_equal_hash( $self->{modules}, $condition->modules ));

    return $self; 
}

sub _is_equal {
    my ( $val1, $val2 ) = @_;

    return 1 if ( ( ! defined $val1 ) && ( ! defined $val2 ) );
    return 1 if ( ( defined $val1 ) && ( defined $val2 ) && $val1 eq $val2 );

    return;
}

sub _is_equal_hash {
    my ( $val1, $val2 ) = @_;

    return 1 if ( ( ! defined $val1 ) && ( ! defined $val2 ) );

    my $str1 = join( '', keys %{ $val1 } ) if ( defined $val1 );
    my $str2 = join( '', keys %{ $val2 } ) if ( defined $val2 );

    return 1 if ( ( defined $val1 ) && ( defined $val2 ) && $str1 eq $str2 );

    return;
}

1;
