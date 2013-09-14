package Blender::Definition;

use 5.012;
use warnings;

use Module::Load;
use Module::Load::Conditional qw/can_load/;

require Blender::Error;

sub new {
    my $class = shift;
    my $name = shift;

    my $self = {
        defined => {
            AdditionalArgument  =>  undef,
            AllowedCondition    =>  undef,
            ArchiveName         =>  undef,
            CopyFiles           =>  undef,
            Dependencies        =>  undef,
            DistName            =>  undef,
            DownloadSite        =>  undef,
            Extension           =>  undef,
            Filename            =>  undef,
            IndexParserForm     =>  undef,
            IndexSite           =>  undef,
            PatchFiles          =>  undef,
            Prefix              =>  undef,
            URL                 =>  undef,
            SortedVersionList   =>  undef,
            Version             =>  undef,
            VersionList         =>  undef,
#           VersionCondition    =>  undef,
            VersionForm         =>  undef,
            WebSite             =>  undef,
            
            CommandConfigure    =>  undef,
            CommandMake         =>  undef,
            CommandTest         =>  undef,
            CommandInstall      =>  undef,
        },
    };

    my $module = 'Blender::Definition::' . ucfirst( $name );

    if ( can_load( modules => { $module => undef } ) ) {
        bless $self, $module;

        $self->initialize;

        return $self;
    }

    die( Blender::Error->new( "no definition for target '$name'" ));
}

sub initialize {

    # do nothing ... virtual method

}

sub parse {
    my $self = shift;

    require Blender::Target::AttributeCollector;
    my $attributes = Blender::Target::AttributeCollector->new;

    foreach my $attribute ( keys %{ $self->{defined} } ) {
        $attributes->add( $attribute, $self->{defined}{ $attribute } );
    }

    return $attributes;
}

1;
