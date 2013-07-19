package Blender::Config;

use 5.012;
use warnings;

use Carp;
use Scalar::Util qw/blessed/;

require Blender::Exception;

sub new {
    my $class = shift;

    my $self = {
        name        =>  undef,
        installed   =>  {},
        enabled     =>  undef,
        modules     =>  {},
        @_,
    };

    bless $self, $class;

    unless ( $self->{name} ) {
        croak( Blender::Exception->new( "'$class' requires name" ) );
    }

    return $self;
}

sub name {
    return $_[0]->{name};
}

sub condition {
    my ( $self, $version ) = @_;

    require Blender::Condition;

    if ( ! $version ) {
        return  Blender::Condition->new(
                name => $self->{name},
                %{ $self->{installed}{$self->enabled} }
                );
    }

    if ( exists $self->{installed}{$version} ) {
        return Blender::Condition->new(
                name => $self->{name},
                %{ $self->{installed}{$version} }
                );
    }

    return;
}

sub is_installed_version {
    my ( $self, $version ) = @_;

    return unless $version;
    return unless keys %{ $self->{installed} };

    return $version if ( exists $self->{installed}{$version} );

    return;
}

sub enabled {
    return $_[0]->{enabled};
}

sub drop_enabled {
    my $self = shift;

    $self->{enabled} = undef;
}

sub set_enabled {
    my ( $self, $version, $condition ) = @_;

    if ( ! $version ) {
        my $err = "set_enabled method requires version string parameter"; 
        croak( Blender::Exception->new( $err ));
    }

    if ( ! $condition ) {
        my $err = "set_enabled method requires condition object";
        croak( Blender::Exception->new( $err ));
    }

    if ( $self->name ne $condition->name ) {
        my $err = "condition's name don't match config's name";
        croak( Blender::Exception->new( $err ));
    }

    $self->{enabled} = $version;
    $self->{installed}{$version} = $condition->serialize_without_name;

    return $self->{enabled};
}

sub modules {
    my $self = shift;

    return $self->{modules} if ( keys %{ $self->{modules} } );

    return;
}

sub set_modules {
    my ( $self, $modules ) = @_;

    $self->{modules} = $modules;

    return $self->modules;
}

sub serialize {
    my $self = shift;

    my %serialized;
    foreach my $key ( keys %{ $self } ) {
        $serialized{ $key } = $self->{$key};
    }

    return \%serialized;
}

1;
