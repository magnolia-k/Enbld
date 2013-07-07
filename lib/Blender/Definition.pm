package Blender::Definition;

use 5.012;
use warnings;

sub new {
    my $class = shift;

    my $self = {
        defined => {
            AdditionalArgument  =>  undef,
            AllowedCondition    =>  undef,
            ArchiveName         =>  undef,
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

    bless $self, $class;

    $self->initialize;

    return $self;
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
