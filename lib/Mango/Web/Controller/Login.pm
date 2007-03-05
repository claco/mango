package Mango::Web::Controller::Login;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Mango::Web::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index : Private {
    my ($self, $c) = @_;
    $c->stash->{'template'} = 'login/default';

    if (!$c->user_exists) {
        if ($c->login) {

        };
    };
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
