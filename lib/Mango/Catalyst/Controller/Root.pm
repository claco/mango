package Mango::Catalyst::Controller::Root;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::Controller/;

    __PACKAGE__->config->{'namespace'} = '';
};

sub index : Template('index') {
    my ($self, $c) = @_;

};

sub default : Template('errors/404') {
    my ($self, $c) = @_;

};

sub end : ActionClass('RenderView') {
    my ($self, $c) = @_;

};

1;
__END__