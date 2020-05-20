package Koha::Plugin::Dcook::OaipmhImport;

use Modern::Perl;

use base qw(Koha::Plugins::Base);

use Mojo::JSON qw(decode_json);

our $VERSION = "v0.0.1";
our $MINIMUM_VERSION = "19.11";

our $metadata = {
    name            => 'OAI-PMH Import Plugin',
    author          => 'David Cook',
    date_authored   => '2020-05-20',
    date_updated    => '2020-05-20',
    minimum_version => $MINIMUM_VERSION,
    maximum_version => undef,
    version         => $VERSION,
    description     => 'This plugin provides an API endpoint for '
        . 'importing OAI-PMH records into Koha',
};

## This is the minimum code required for a plugin's 'new' method
## More can be added, but none should be removed
sub new {
    my ( $class, $args ) = @_;

    ## We need to add our metadata here so our base class can access it
    $args->{'metadata'} = $metadata;
    $args->{'metadata'}->{'class'} = $class;

    ## Here, we call the 'new' method for our base class
    ## This runs some additional magic and checking
    ## and returns our actual $self
    my $self = $class->SUPER::new($args);

    return $self;
}

#sub tool {}
#sub configure { }

#sub install {}
#sub upgrade {}
#sub uninstall {}

sub api_routes {
    my ( $self, $args ) = @_;

    my $spec_str = $self->mbf_read('openapi.json');
    my $spec     = decode_json($spec_str);

    return $spec;
}

sub api_namespace {
    my ( $self ) = @_;
    
    return 'oaipmhimport';
}
