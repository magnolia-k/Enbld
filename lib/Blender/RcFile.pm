package Blender::RcFile;

use 5.012;
use warnings;

use autodie;
use File::Spec;
use File::Path qw/make_path/;
use File::Temp;
use File::Copy;

use Carp;

require Blender::Message;
require Blender::Error;
require Blender::Exception;

sub new {
    my $class = shift;

    my $self = {
        filepath    =>  undef,
        directory   =>  undef,
        url         =>  undef,
        contents    =>  undef,
        fullpath    =>  undef,
        filename    =>  undef,
        command     =>  undef,
        @_,
    };

    bless $self, $class;

    $self->{directory} = $ENV{HOME} unless $self->{directory};
    $self->_parse_filepath;

    return $self;
}

sub do {
    my $self = shift;

    if ( ( $self->{command} eq 'load' ) && ( ! $self->{url} ) ) {
        _err( "Configuration 'load' command needs 'from' command." );
    }

    if ( ( $self->{command} eq 'set' ) && ( $self->{url} ) ) {
        _err( "Configuration 'set' command don't need 'from' command." );
    }

    my $result;

    if ( $self->{command} eq 'load' ) {
        $result = $self->load;
    } elsif ( $self->{command} eq 'set' ) {
        $result = $self->set;
    }

    return $result;
}

sub _parse_filepath {
    my $self = shift;

    if ( ! $self->{filepath} ) {
        _err( "Configuration file's path not set." );
    }

   $self->{fullpath} = File::Spec->file_name_is_absolute( $self->{filepath} ) ?
        $self->{filepath} :
        File::Spec->catfile( $self->{directory}, $self->{filepath} );

    my ( undef, $dirs, $filename ) = File::Spec->splitpath( $self->{fullpath} );

    $self->{filename} = $filename;

    if ( ! _check_permission( $dirs )) {
        _err( "Please check write permission for $dirs." );
    }

    return $self->{fullpath};
}

sub _check_permission {
    my $dir = shift;

    my @list = File::Spec->splitdir( $dir );

    while( @list ) {
        my $path = File::Spec->catdir( @list );

        return $path if ( -d -w $path );

        pop @list;
    }

    return;
}

sub load {
    my $self = shift;

    return if ( -e $self->{fullpath} );

    my $temp = File::Temp->newdir;

    chdir $temp;

    Blender::Message->notify(
            "=====> Load configuration file '$self->{filename}'" .
            " from '$self-{url}'."
            );

    system( 'curl', '-O', $self->{url}, '-s' );

    chdir $ENV{HOME};

    my $path = File::Spec->catfile( $temp, $self->{filename} );
    unless ( -f -T $path )  {
       _err( "Configuration file '$self->{filename}' isn't text file." ); 
    }

    if ( $self->{contents} ) {
        open my $temphandle, '>>', $path;
        print $temphandle $self->{contents};
        close $temphandle;
    }

    if ( copy( $path, $self->{fullpath} )) {

        Blender::Message->notify(
                "=====> Finish configuration file '$self->{filename}'"
                );

        return $self->{filename};
    }

    _err( "Can't write $self->{fullpath}:$!" );    
}

sub set {
    my $self = shift;

    return if ( -e $self->{fullpath} );

    Blender::Message->notify(
            "=====> Set configuration file '$self->{filename}'"
            );

    my ( undef, $dirs, $file ) = File::Spec->splitpath( $self->{fullpath} );
    make_path( $dirs );

    open my $fh, '>', $self->{fullpath};
    print $fh $self->{contents};
    close $fh;

    Blender::Message->notify(
            "=====> Finish configuration file '$self->{filename}'"
            );

    return $self->{filename};
}

sub filename {
    my $self = shift;

    return $self->{filename};
}

sub serialize {
    my $self = shift;

    my $serialized;

    $serialized->{filepath}  = $self->{filepath};
    $serialized->{command}   = $self->{command};
    $serialized->{contents}  = $self->{contents} if $self->{contents};

    if ( $self->{directory} ne $ENV{HOME} ) {
        $serialized->{directory} = $self->{directory};
    }

    if ( $self->{url} ) {
        $serialized->{url} = $self->{url};
    }

    return $serialized;
}

sub DSL {
    my $self = shift;

    my @rcfile;

    my $str = "conf '" . $self->{filepath} . "' => " . $self->{command} . " {\n";

    push @rcfile, $str;

    if ( $self->{url} ) {
        push @rcfile, '    ' . "from '" . $self->{url} . "';\n";
    }

    if ( $self->{directory} ne $ENV{HOME} ) {
        push @rcfile, '    ' . "to '" . $self->{directory} . "';\n";
    }

    if ( $self->{contents} ) {
        my @contents = split( "\n", $self->{contents} ); 

        foreach my $line ( @contents ) {
            push @rcfile, '    ' . "content '" . $line . "';\n";
        }
    }

    push @rcfile, "};\n";

    return \@rcfile;
}

sub _err {
    my $err = shift;
    my $param = shift;

    die( Blender::Error->new( $err, $param ));
}

sub _exception {
    my $exception = shift;
    my $param = shift;

    croak( Blender::Exception->new( $exception, $param ));
}

1;
