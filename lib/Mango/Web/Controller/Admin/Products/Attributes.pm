package Mango::Web::Controller::Admin::Products::Attributes;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Web::Base::Form/;
    use FormValidator::Simple::Constants;
    use Set::Scalar ();
};

=head1 NAME

Mango::Web::Controller::Admin::Products::Attributes - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : PathPart('attributes') Chained('/admin/products/load') Args(0) {
    my ($self, $c) = @_;

    warn "LOAD ALL ATTRIBUTES";
};

sub load : PathPart('attributes') Chained('/admin/products/load') CaptureArgs(1) {
    my ($self, $c, $id) = @_;

    warn "LOAD ATTRIBUTE $id";
};

sub create : PathPart('attributes/create') Chained('/admin/products/load') Args(0) {
    my ($self, $c) = @_;

    warn "CREATE ATTRIBUTE";
};

sub edit : PathPart('edit') Chained('load') Args(0) {
    my ($self, $c) = @_;

    warn "EDIT ATTRIBUTE";
};

# /admin/products/create
# /admin/products/1/edit
# /admin/products/1/attributes
# /admin/products/1/attributes/create
# /admin/products/1/attributes/2/edit


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
