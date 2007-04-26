# $Id$
package Mango::Catalyst::Model::Roles;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Model::Provider/;
};

__PACKAGE__->config(
    provider => 'Mango::Provider::Roles'
);

=head1 NAME

Mango::Web::Model::Roles - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
