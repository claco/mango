# $Id$
package Mango::Web::View::HTML;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::View::TT/;
};

sub process {
    my ($self, $c) = (shift, shift);

    $self->NEXT::process($c, @_);
    $c->res->content_type('text/html; charset=utf-8');

    return 1;
};

1;
__END__

=head1 NAME

Mango::Web::View::XHTML - Catalyst view class for Mango::Web

=head1 SYNOPSIS

    $c->view('XHTML');

=head1 DESCRIPTION

Mango::Web::View::XHTML is the default Template Toolkit view for the Mango Web
application.

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
