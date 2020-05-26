package Koha::Plugin::Dcook::OaipmhImport::RecordModel;

use Modern::Perl;

use XML::LibXML::Reader;

my $xpc = XML::LibXML::XPathContext->new();
$xpc->registerNs('oai','http://www.openarchives.org/OAI/2.0/');
my $xpath_identifier = XML::LibXML::XPathExpression->new("oai:header/oai:identifier");
my $xpath_datestamp = XML::LibXML::XPathExpression->new("oai:header/oai:datestamp");
my $xpath_status = XML::LibXML::XPathExpression->new(q{oai:header/@status});

=head1 API Model

=head2 Class Methods

=head3 Method that imports bibliographic records from OAI-PMH

=cut

sub new {
    my ($class, $args) = @_;
    $args = {} unless defined $args;
    return bless ($args, $class);
}

sub process_metadata {
    my ($self, $args) = @_;
	my $added = 0;
	my $updated = 0;
	my $deleted = 0;
    my $records = $args->{records};
    if ($records) {
        if ($self->{type} && $self->{type} eq 'biblio'){
			my $reader = XML::LibXML::Reader->new( string => $records );
			my $pattern = XML::LibXML::Pattern->new('oai:OAI-PMH|/oai:OAI-PMH/*', { 'oai' => "http://www.openarchives.org/OAI/2.0/" });
			my $repository;
			while (my $rv = $reader->nextPatternMatch($pattern)){
				#NOTE: We do this so we only get the opening tag of the element.
				next unless $reader->nodeType == XML_READER_TYPE_ELEMENT;

				my $localname = $reader->localName;
				if ( $localname eq "request" ){
					my $node = $reader->copyCurrentNode(1);
					$repository = $node->textContent;
				}
				elsif ( ($localname eq "ListRecords") || ($localname eq "GetRecord") ){
					my $each_pattern = XML::LibXML::Pattern->new('//oai:record', { 'oai' => "http://www.openarchives.org/OAI/2.0/" });
					while (my $each_rv =  $reader->nextPatternMatch($each_pattern)){
						next unless $reader->nodeType == XML_READER_TYPE_ELEMENT;
						if ($reader->localName eq "record"){
							my $record_node = $reader->copyCurrentNode(1);
                            if ($record_node){
                                my $document = XML::LibXML::Document->new('1.0', 'UTF-8');
                                $document->setDocumentElement($record_node);
                                my $root = $document->documentElement;

                                my $identifier_node = $xpc->findnodes($xpath_identifier,$root)->shift;
                                warn $identifier_node->textContent;
                                my $datestamp_node = $xpc->findnodes($xpath_datestamp,$root)->shift;
                                warn $datestamp_node->textContent;
                                my $status_node = $xpc->findnodes($xpath_status,$root)->shift;
                                warn $status_node->textContent if $status_node;
                                my $deleted;

                                #TODO:
                                #my $record_id = _retrieve_record();
                                #if ($record_id) {
                                #   if deleted, delete record
                                #   if not deleted, update record, if this record is newer than existing record
                                #} else {
                                #   #if not deleted
                                #   $record_id = _create_record();
                                #}
                            }
						}
					}
				}
			}
        }
    }
	return ($added,$updated,$deleted);
}

sub _create_record {
    my ($self, $args) = @_;
    my $repository = $args->{repository};
    my $identifier = $args->{identifier};
    my $datestamp = $args->{datestamp};
    my $metadta = $args->{metadata};
    #TODO
}

sub _retrieve_record {
    my ($self, $args) = @_;
    my $repository = $args->{repository};
    my $identifier = $args->{identifier};
    #TODO
}

sub _update_record {
    my ($self, $args) = @_;
    my $record_id = $args->{record_id};
    my $datestamp = $args->{datestamp};
    my $metadta = $args->{metadata};
    #TODO
}

sub _delete_record {
    my ($self, $args) = @_;
    my $record_id = $args->{record_id};
    #TODO
}
