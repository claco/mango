package Mango::Catalyst::Controller::REST;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::Controller::REST/;
    use MIME::Types;
};

__PACKAGE__->config(
    serialize => {
        'map'       => {
            'text/plain'            => [qw/View Text/],
            'text/html'             => [qw/View HTML/],
            'application/xhtml+xml' => [qw/View XHTML/],
            'application/rss+xml'   => [qw/View RSS/],
            'application/atom+xml'  => [qw/View Atom/],
        }
    }
);

my $mimes = MIME::Types->new;
$mimes->addType(
    MIME::Type->new(
        type => 'text/x-json',
        extensions => [qw/json/]
    )
);
$mimes->addType(
    MIME::Type->new(
        type => 'text/x-yaml',
        extensions => [qw/yml yaml/]
    )
);
$mimes->addType(
    MIME::Type->new(
        type => 'application/atom+xml',
        extensions => [qw/atom/]
    )
);
$mimes->addType(
    MIME::Type->new(
        type => 'application/rss+xml',
        extensions => [qw/rss/]
    )
);
$mimes->addType(
    MIME::Type->new(
        type => 'text/plain',
        extensions => [qw/text txt/]
    )
);

sub begin : Private {
    my ($self, $c) = @_;
    my $view = $c->req->param('view') || 'html';

    $c->request->content_type(
        $mimes->mimeTypeOf($view)
    ) if $view;
    
    $self->NEXT::begin($c); 
};

1;
