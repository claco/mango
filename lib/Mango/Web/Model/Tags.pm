# $Id: Roles.pm 1665 2007-01-21 04:28:40Z claco $
package Mango::Web::Model::Tags;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::Model::Mango::Provider/;
};

__PACKAGE__->config(
    provider => 'Mango::Provider::Tags'
);

=head1 NAME

Mango::Web::Model::Tags - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
