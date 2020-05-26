package Koha::Plugin::Dcook::OaipmhImport;

use Modern::Perl;
use Mojo::JSON qw(decode_json);

use base qw(Koha::Plugins::Base);

use C4::Context;
use Koha::DateUtils;

our $VERSION = "0.0.1";
our $MINIMUM_VERSION = "19.11";

our $metadata = {
    name            => 'OAI-PMH Import Plugin',
    author          => 'David Cook',
    date_authored   => '2020-05-20',
    date_updated    => '2020-05-26',
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

sub install {
    my ( $self, $args ) = @_;
    my $table = $self->get_qualified_table_name('biblios');

    return C4::Context->dbh->do( "
        CREATE TABLE IF NOT EXISTS $table (
            `id` INT( 10 ) UNSIGNED NOT NULL AUTO_INCREMENT,
            `repository` MEDIUMTEXT NOT NULL, -- this is a URL so it needs to be long
            `identifier` MEDIUMTEXT NOT NULL, -- this is technically a URI
            `datestamp` datetime NOT NULL, -- this is a UTC timestamp
            `biblionumber` INT( 11 ) NOT NULL,
            PRIMARY KEY (`id`),
            KEY `FK_oaipmh_import_biblios_1` (`biblionumber`),
            CONSTRAINT `FK_oaipmh_import_biblios_1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE NO ACTION
        ) ENGINE = INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    " );
}

sub upgrade {
    my ( $self, $args ) = @_;

    my $dt = dt_from_string();
    $self->store_data( { last_upgraded => $dt->ymd('-') . ' ' . $dt->hms(':') } );

    return 1;
}

sub uninstall() {
    my ( $self, $args ) = @_;

    my $table = $self->get_qualified_table_name('oaipmh_import_biblios');

    return C4::Context->dbh->do("DROP TABLE IF EXISTS $table");
}

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
