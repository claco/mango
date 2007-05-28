package Mango::Catalyst::Controller::REST;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::Controller::REST/;
    use MIME::Types;
};

__PACKAGE__->config(
    serialize => {
        'stash_key' => 'entity',
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
    my $view = $c->request->param('view') || 'html';

    $c->request->content_type(
        $mimes->mimeTypeOf($view)
    ) if $view;

    $self->NEXT::begin($c);
};

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

By default, REST looks for data in the C<entity> stash key, for forwards to the
appropriate view based on the Content-Type header, or the C<view> parameter.

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

=head1 SEE ALSO

L<Catalyst::Action::REST>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
