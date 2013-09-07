package Blender::Exception;

use 5.012;
use warnings;

use Carp;
use Data::Dumper;

use overload (
        q{""} => \&to_string,
        fallback => 1,
        );

sub new {
    my ( $class, $message, $param ) = @_;

    chomp( $message );

    if ( $param ) { $message .= "\n" . Dumper( $param ) };

    my $location = $ENV{HARNESS_ACTIVE} ? Carp::longmess() : Carp::shortmess();

    my $self = {
        message         =>  $message,
        caller_location =>  $location,
    };

    return bless $self, $class;
}

sub to_string {
    my $self = shift;

    return "ABORT:$self->{message}$self->{caller_location}";
}

1;
