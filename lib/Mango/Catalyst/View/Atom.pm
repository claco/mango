package Mango::Catalyst::View::Atom;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::View::Feed/;
};

sub process {
    my($self, $c) = @_;

    $self->NEXT::process($c, 'Atom');
    $c->res->content_type('application/atom+xml; charset=utf-8');

    return 1;
};

1; 
