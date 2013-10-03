package Enbld::HTTP;

use 5.012;
use warnings;

use File::Spec;
use Carp;

require Enbld::Message;

our $get_hook;
our $download_hook;

our $client;

my $curl = `which curl`;
my $wget = `which wget`;

if ( $wget ) {
	$client = $wget;
} elsif ( $curl ) {
	$client = $curl;
} else {
	croak "You must install wget or curl";
}

sub new {
    my ( $class, $url ) = @_;

    my $pattern = q{s?https?://[-_.!~*'()a-zA-Z0-9;/?:@&=+$,%#]+};

    if ( $url !~ /^$pattern$/ ) {
        require Enbld::Exception;
        croak( Enbld::Exception->new( "'$url' isn't valid URL string" ));
    }

    my $self = {
        url =>  $url,
    };

    return bless $self, $class;
}

sub download {
    my ( $self, $path ) = @_;

    my ( undef, undef, $file ) = File::Spec->splitpath( $path );

    if ( -e $path ) {
        my $msg = "--> Use file '$file' that is previously downloaded.";
        Enbld::Message->notify( $msg );
        return $path;
    }

    if ( $download_hook ) {
        $download_hook->( $self, $path );
        return $path;
    }

    Enbld::Message->notify( "--> Download '$file' from '$self->{url}'." );

	if ( $client eq 'wget' ) {
		system( 'wget', $self->{url}, '-O', $path, '-q' );
	} else {
	    system( 'curl', '-L', $self->{url}, '-o', $path, '-s', '-f' );
	}

    return $path unless $?;

    if ( -e $path ) {
        unlink $path;
    }

    if ( $? == -1 ) {
        die( Enbld::Error->new( "Failed to execute http client:$client" ));
    } elsif ( $? & 127 ) {
        my $err = "Http client died with signal.";
        die( Enbld::Error->new( $err ));
    } else {
        my $err = 'Download request returns error.';
        die( Enbld::Error->new( $err , ( $? >> 8 ) ));
    }
}

sub download_archivefile {
    my ( $self, $path ) = @_;

    my $downloaded = $self->download( $path );

    require Enbld::Archivefile;
    return Enbld::Archivefile->new( $downloaded );
}

sub get {
    my $self = shift;

    if ( $get_hook ) {
        return $get_hook->( $self );
    }

	my $res;

	if ( $client eq 'wget' ) {
		$res = `wget $self->{url} -q -O -`;
	} else {
	    $res = `curl -s -f --compressed -L $self->{url}`;
	}

    if ( $? >> 8 ) {
        my $err = 'HTTP get request returns error.';
        die( Enbld::Error->new( $err, ( $? >> 8) ));
    }

    return $res;
}

sub get_html {
    my $self = shift;

    my $content = $self->get;

    require Enbld::HTML;
    return Enbld::HTML->new( $content );
}

sub register_get_hook {
    my ( $pkg, $coderef ) = @_;

    if ( ref( $coderef ) eq 'CODE' ) {
        $get_hook = $coderef;
        return $pkg;
    }

    my $err = "register get hook requires CODE reference parameter.";
    require Enbld::Exception;
    croak( Enbld::Exception->new( $err, $coderef ));
}

sub register_download_hook {
    my ( $pkg, $coderef ) = @_;

    if ( ref( $coderef ) eq 'CODE' ) {
        $download_hook = $coderef;
        return $pkg;
    }

    my $err = "register download hook requires CODE reference parameter.";
    require Enbld::Exception;
    croak( Enbld::Exception->new( $err, $coderef ));
}

1;
