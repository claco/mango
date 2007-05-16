# $Id$
package Mango::Catalyst::View::XHTML;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::View::TT/;
};

sub process {
    my ($self, $c) = (shift, shift);

    $self->NEXT::process($c, @_);
    $c->response->content_type('application/xhtml+xml; charset=utf-8');

    return 1;
};

1;
__END__

=head1 NAME

Mango::Catalyst::View::XHTML - View class for XHTML output

=head1 SYNOPSIS

    $c->view('XHTML');

=head1 DESCRIPTION

Mango::Catalyst::View::XHTML renders content using Catalyst::View::TT and
serves it with the following content type:

    application/xhtml+xml; charset=utf-8

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
