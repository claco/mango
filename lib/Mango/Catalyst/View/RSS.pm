package Mango::Catalyst::View::RSS;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::View::Feed/;
};

sub process {
    my($self, $c) = @_;

    $self->NEXT::process($c, 'RSS');
    $c->res->content_type('application/rss+xml; charset=utf-8');

    return 1;
};

1; 
