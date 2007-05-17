# $Id$
package Mango::Catalyst::View::RSS;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::View::Feed/;
};

sub process {
    my($self, $c) = @_;

    $self->NEXT::process($c, 'RSS');
    $c->response->content_type('application/rss+xml; charset=utf-8');

    return 1;
};

1;
__END__

=head1 NAME

Mango::Catalyst::View::RSS - View class for RSS feeds

=head1 SYNOPSIS

    $c->view('RSS');

=head1 DESCRIPTION

Mango::Catalyst::View::RSS renders content using XML::Feed and
serves it with the following content type:

    application/rss+xml; charset=utf-8

=head1 METHODS

=head2 process

Creates an XML::Feed of the specific type, writes it to the response body,
and changes the content type. There is usually no reason to call this method
directly. Forward to this view instead:

    $c->forward($c->view('RSS'));

=head1 SEE ALSO

L<Mango::Catalyst::View::Feed>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
