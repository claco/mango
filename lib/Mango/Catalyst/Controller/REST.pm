# $Id$
package Mango::Catalyst::Controller::REST;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::Controller::REST/;
    use MIME::Types  ();
    use Scalar::Util ();

    __PACKAGE__->config(
        'stash_key' => 'entity',
        'default'   => 'text/html',
        'map'       => {
            'text/plain'            => [qw/View Text/],
            'text/html'             => [qw/View HTML/],
            'application/xhtml+xml' => [qw/View XHTML/],
            'application/rss+xml'   => [qw/View RSS/],
            'application/atom+xml'  => [qw/View Atom/],

            ## remap unwanted accepted types until we get more REST
            ## config for weighting
            'text/xml' => [qw/View HTML/],
        }
    );
}

my $mimes = MIME::Types->new;
$mimes->addType(
    MIME::Type->new(
        type       => 'text/x-json',
        extensions => [qw/json/]
    )
);
$mimes->addType(
    MIME::Type->new(
        type       => 'text/x-yaml',
        extensions => [qw/yml yaml/]
    )
);
$mimes->addType(
    MIME::Type->new(
        type       => 'application/atom+xml',
        extensions => [qw/atom/]
    )
);
$mimes->addType(
    MIME::Type->new(
        type       => 'application/rss+xml',
        extensions => [qw/rss/]
    )
);
$mimes->addType(
    MIME::Type->new(
        type       => 'text/plain',
        extensions => [qw/text txt/]
    )
);

sub ACCEPT_CONTEXT {
    my $self = shift;
    my $c    = shift;

    if ( !$c->request->header('Accept') ) {
        $c->request->content_type( $self->{'default'} );
    }

    ## friendly view name overrides header
    my $view = $c->request->param('view');
    if ($view) {
        $c->request->content_type( $mimes->mimeTypeOf($view) );
    }

    ## type param overrides header
    my $type = $c->request->param('content-type');
    if ($type) {
        $c->request->content_type($type);
    }

    ## change method if we're faking it through crippled client POST
    if ( $c->request->method eq 'POST' && $c->request->param('_method') ) {
        $c->request->method( uc $c->request->param('_method') );
    }

    return $self->NEXT::ACCEPT_CONTEXT( $c, @_ ) || $self;
}

sub end : ActionClass('Serialize') {
    my $self = shift;
    my $c    = shift;
    $self->NEXT::end( $c, @_ );

    $c->response->content_type( $c->request->preferred_content_type );
    $c->response->body('');

    return;
}

sub entity {
    my ( $self, $data, $pager ) = @_;
    my $key = $self->{'stash_key'};

    if ( defined $data ) {
        if ( Scalar::Util::blessed $pager && $pager->isa('Data::Page') ) {
            $data->{'current_page'}     = $pager->current_page;
            $data->{'entries_per_page'} = $pager->entries_per_page;
            $data->{'total_entries'}    = $pager->total_entries;
            $data->{'first_page'}       = $pager->first_page;
            $data->{'last_page'}        = $pager->last_page;
        }

        $self->context->stash->{$key} = $data;
    }

    return $self->context->stash->{$key} || $self->context->request->data;
}

sub wants_atom {
    my $self = shift;
    my $c    = $self->context;

    return $c->request->preferred_content_type eq $mimes->mimeTypeOf('atom');
}

sub wants_rss {
    my $self = shift;
    my $c    = $self->context;

    return $c->request->preferred_content_type eq $mimes->mimeTypeOf('rss');
}

sub wants_json {
    my $self = shift;
    my $c    = $self->context;

    return $c->request->preferred_content_type eq $mimes->mimeTypeOf('json');
}

sub wants_yaml {
    my $self = shift;
    my $c    = $self->context;

    return $c->request->preferred_content_type eq $mimes->mimeTypeOf('yaml');
}

sub wants_html {
    my $self = shift;
    my $c    = $self->context;

    return $c->request->preferred_content_type eq $mimes->mimeTypeOf('html');
}

sub wants_xhtml {
    my $self = shift;
    my $c    = $self->context;

    return $c->request->preferred_content_type eq $mimes->mimeTypeOf('xhtml');
}

sub wants_text {
    my $self = shift;
    my $c    = $self->context;

    return $c->request->preferred_content_type eq $mimes->mimeTypeOf('text');
}

sub wants_browser {
    my $self = shift;
    my $c    = $self->context;

    return
         $self->wants_html
      || $self->wants_xhtml
      || $self->wants_text
      || $c->request->preferred_content_type eq
      'application/x-www-form-urlencoded';
}

sub wants_feed {
    my $self = shift;

    return $self->wants_atom
      || $self->wants_rss;
}

1;
__END__

=head1 NAME

Mango::Catalyst::Controller::REST - Catalyst controller for REST based activity.

=head1 SYNOPSIS

    package MyApp::Controller::Stuff;
    use base qw/Mango::Catalyst:Controller::REST/;
    
    sub load : Local {
        my ($self, $c, $id) = @_;
        my $user = $c->model('Users')->get_by_id($id);
    
        $c->stash->{'entity'} = $user;
    };
    
    http://localhost/user/1?view=json

=head1 DESCRIPTION

Mango::Catalyst::Controller::REST is a base Catalyst controller that
automatically enables REST activity on actions in that controller using
Catalyst::Action::REST.

By default, REST looks for data in the C<entity> stash key, for forwards to
the appropriate view based on the Content-Type header, or the C<view>
parameter.

In addition to the formats supported by Catalyst::Action;:REST, the following
has been added:

    Content-Type:
        'text/plain'            => [qw/View Text/],
        'text/html'             => [qw/View HTML/],
        'application/xhtml+xml' => [qw/View XHTML/],
        'application/rss+xml'   => [qw/View RSS/],
        'application/atom+xml'  => [qw/View Atom/],

    view parameter:
        txt, text => [qw/View Text/],
        htm, html => [qw/View HTML/],
        xhtml     => [qw/View XHTML/],
        rss       => [qw/View RSS/],
        atom      => [qw/View Atom/],
        json      => JSON
        yml, yaml => YAML

=head1 METHODS

=head2 entity

=over

=item Arguments: $data, $pager

=back

Gets/sets the entity data used for RESTish requests and responses.

=head2 wants_atom

Returns true if the client is requesting an atom feed.

=head2 wants_feed

Returns true if the client is requesting a feed (atom/rss).

=head2 wants_rss

Returns true if the client is requesting an rss feed.

=head2 wants_browser

Returns true if the client appears to be a a web browser and/or is requesting
html-like resources.

=head2 wants_html

Returns true if the client is requesting html.

=head2 wants_xhtml

Returns true if the client is requesting xhtml.

=head2 wants_json

Returns true if the client is requesting json.

=head2 wants_yaml

Returns true if the client is requesting yaml.

=head2 wants_text

Returns true if the client is requesting text.

=head1 SEE ALSO

L<Catalyst::Action::REST>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
