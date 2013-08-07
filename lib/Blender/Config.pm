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

    $self->{enabled} = $version;
    $self->{installed}{$version} = $condition->serialize_without_name;

    return $self->{enabled};
}

sub serialize {
    my $self = shift;

    my $serialized;
    foreach my $key ( sort keys %{ $self } ) {
        $serialized->{$key} = $self->{$key};
    }

    return $serialized;
}

sub DSL {
    my $self = shift;

    my @config;

    require Blender::Feature;
    my $version = Blender::Feature->is_current_mode ?
        $self->enabled : $self->condition->version;

    push @config, "target '" . $self->name . "' => define {\n";
    push @config, "    version '". $version . "';\n";
    if ( $self->condition->make_test ) {
        push @config, "    make_test '" . $self->condition->make_test . "';\n";
    }

    if ( $self->condition->modules ) {
        push @config, "    modules {\n";

        foreach my $module ( sort keys %{ $self->condition->modules } ) {
            push @config, ' ' x 8 . "'" . $module . "' => " . 
                $self->condition->modules->{$module} . ",\n";
        }

        push @config, "    };\n";
    }

    push @config, "};\n";

    return \@config;
}

1;
