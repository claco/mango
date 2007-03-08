package Mango::Web::Controller::Tags;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Mango::Web::Controller::Tags - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub default : Private {
    my ($self, $c, @tags) = @_;

    shift @tags;

    my $products = $c->model('Products')->get_by_tags(@tags);

    $c->response->body($products->count);
};


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
