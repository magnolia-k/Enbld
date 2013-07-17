package Blender::HTTP;

use 5.012;
use warnings;

use File::Spec;
use Carp;

require Blender::Message;

our $get_hook;
our $download_hook;

sub new {
    my ( $class, $url ) = @_;

    my $pattern = q{s?https?://[-_.!~*'()a-zA-Z0-9;/?:@&=+$,%#]+};

    if ( $url !~ /^$pattern$/ ) {
        require Blender::Exception;
        croak( Blender::Exception->new( "'$url' isn't valid URL string" ));
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
        my $msg = "-----> Use file '$file' that is previously downloaded.";
        Blender::Message->notify( $msg );
        return $path;
    }

    if ( $download_hook ) {
        $download_hook->( $self, $path );
        return $path;
    }

    Blender::Message->notify( "-----> Download '$file' from '$self->{url}'." );

    system( 'curl', '-L', $self->{url}, '-o', $path, '-s', '-f' );

    if ( $? >> 8 ) {
        my $err = 'download request returns error.';
        die( Blender::Error->new( $err , ( $? >> 8 ) ));
    }

    return $path;
}

sub download_archivefile {
    my ( $self, $path ) = @_;

    my $downloaded = $self->download( $path );

    require Blender::Archivefile;
    return Blender::Archivefile->new( $downloaded );
}

sub get {
    my $self = shift;

    if ( $get_hook ) {
        return $get_hook->( $self );
    }

    my $res = `curl -L $self->{url} -s -f`;

    if ( $? >> 8 ) {
        my $err = 'HTTP get request returns error.';
        die( Blender::Error->new( $err, ( $? >> 8) ));
    }

    return $res;
}

sub get_html {
    my $self = shift;

    my $content = $self->get;

    require Blender::HTML;
    return Blender::HTML->new( $content );
}

sub register_get_hook {
    my ( $pkg, $coderef ) = @_;

    if ( ref( $coderef ) eq 'CODE' ) {
        $get_hook = $coderef;
        return $pkg;
    }

    my $err = "register get hook requires CODE reference parameter.";
    require Blender::Exception;
    croak( Blender::Exception->new( $err, $coderef ));
}

sub register_download_hook {
    my ( $pkg, $coderef ) = @_;

    if ( ref( $coderef ) eq 'CODE' ) {
        $download_hook = $coderef;
        return $pkg;
    }

    my $err = "register download hook requires CODE reference parameter.";
    require Blender::Exception;
    croak( Blender::Exception->new( $err, $coderef ));
}

1;
