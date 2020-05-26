package Koha::Plugin::Dcook::OaipmhImport::RecordController;

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use Koha::Plugin::Dcook::OaipmhImport::RecordModel;

=head1 API

=head2 Class Methods

=head3 Method that imports bibliographic records from OAI-PMH

=cut

sub import_biblio {
    #NOTE: This will only work if we mark the body as optional
    my $c = shift->openapi->valid_input or return;

    my $added = 0;
    my $updated = 0;
    my $deleted = 0;

    #NOTE: Mojolicious::Plugin::OpenAPI expects to only consume JSON
    #my $body = $c->validation->param('body');
    my $body = $c->req->body;
    if ($body) {
        my $model = Koha::Plugin::Dcook::OaipmhImport::RecordModel->new({
            type => 'biblio',
        });

        #TODO: It would be nice to allow them to choose a matcher_code, framework, and maybe a XSLT filter... 
        #TODO: Provide these as query string parameters OR as HTTP headers (like x-koha-embed)?
        #my $frameworkcode = $c->validation->param('frameworkcode');
        #my $matcher_code = $c->validation->param('matcher_code');
        #my $xslt = $c->validation->param('xslt');

        ($added, $updated, $deleted) = $model->process_metadata({
            records => $body,
        });
    } else {
        return $c->render( status => 400, openapi => { error => "Records not found." } );
    }

    return $c->render( status => 200, openapi => { added => $added, updated => $updated, deleted => $deleted, } );
}

1;
