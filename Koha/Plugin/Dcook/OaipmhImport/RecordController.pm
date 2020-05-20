package Koha::Plugin::Dcook::OaipmhImport::RecordController;

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

=head1 API

=head2 Class Methods

=head3 Method that imports bibliographic records from OAI-PMH

=cut

sub import_biblio {
    #NOTE: This will only work if we mark the body as optional
	my $c = shift->openapi->valid_input or return;

    #NOTE: Mojolicious::Plugin::OpenAPI expects to only consume JSON
    #my $body = $c->validation->param('body');
    my $body = $c->req->body;

    unless ($body) {
        return $c->render( status => 400, openapi => { error => "Records not found." } );
    }

    return $c->render( status => 200, openapi => { added => 0, updated => 0, deleted => 0, } );
}

1;
