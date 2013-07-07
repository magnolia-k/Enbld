package Blender::Exception;

use 5.012;
use warnings;

use Carp;
use Data::Dumper;
use Scalar::Util qw/ blessed /;

use overload (
        q{""} => \&to_string,
        fallback => 1,
        );

sub new {
    my ( $class, $message, $param ) = @_;

    chomp( $message );

    if ( $param ) { $message .= "\n" . Dumper( $param ) };

    my $self = {
        message         =>  $message,
        caller_location =>  Carp::longmess(),
    };

    return bless $self, $class;
}

sub caught {
    my $pkg = shift;

    return if ! blessed $@;
    return $@->isa( $pkg );
}

sub to_string {
    my $self = shift;

    return "ABORT:$self->{message}$self->{caller_location}";
}

1;
