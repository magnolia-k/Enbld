package Blender::Error;

use 5.012;
use warnings;

use overload (
        q{""} => 'to_string',
        fallback => 1,
        );

sub new {
    my ( $class, $message ) = @_;

    chomp( $message );

    my $self = {
        message =>  $message,
    };

    return bless $self, $class;
}

sub caught {
    my $pkg = shift;

    use Scalar::Util qw/ blessed /;

    return if ! blessed $@;
    return $@->isa( $pkg );
}

sub to_string {
    my $self = shift;

    return "ERROR:$self->{message}\n";
}

1;
