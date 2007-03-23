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
    $c->stash->{'template'} = 'admin/products/attributes/default';

    my $product = $c->stash->{'product'};

    my $page = $c->request->param('page') || 1;
    my $attributes = $product->attributes(undef, {
        page => $page,
        rows => 1
    });

    $c->stash->{'template'} = 'admin/products/attributes/default';
    $c->stash->{'attributes'} = $attributes;
    $c->stash->{'pager'} = $attributes->pager;
};

sub load : PathPart('attributes') Chained('/admin/products/load') CaptureArgs(1) {
    my ($self, $c, $id) = @_;
    $c->stash->{'template'} = 'admin/products/attributes/edit';

    my $attribute = $c->stash->{'product'}->attributes({
        id => $id
    })->first;

    if ($attribute) {
        $c->stash->{'attribute'} = $attribute;
    } else {
        $c->response->status(404);
        $c->detach;
    };
};

sub create : PathPart('attributes/create') Chained('/admin/products/load') Args(0) {
    my ($self, $c) = @_;
    $c->stash->{'template'} = 'admin/products/attributes/create';

    my $product = $c->stash->{'product'};
    my $form = $c->forward('form');

    ## I love being evil. I'll make plugins eventually, but I don't want
    ## the module clutter at the moment
    local *FormValidator::Simple::Validator::ATTRIBUTE_UNIQUE = sub {
        return $product->attributes({
            name => $form->field('name')
        })->count ? FALSE : TRUE;
    };

    if ($c->forward('submitted') && $c->forward('validate')) {
        my $attribute = $product->add_attribute({
            name => $form->field('name'),
            value => $form->field('value')
        });

        $c->response->redirect(
            $c->uri_for('/admin/products', $product->id, 'attributes', $attribute->id, 'edit/')
        );
    };
};

sub edit : PathPart('edit') Chained('load') Args(0) {
    my ($self, $c) = @_;
    $c->stash->{'template'} = 'admin/products/attributes/edit';

    my $attribute = $c->stash->{'attribute'};
    my $form = $c->forward('form');

    ## I love being evil. I'll make plugins eventually, but I don't want
    ## the module clutter at the moment
    local *FormValidator::Simple::Validator::ATTRIBUTE_UNIQUE = sub {
        if ($attribute->name eq $form->field('name')) {
            return TRUE;
        };
        my $existing = $c->stash->{'product'}->attributes({
            name => $form->field('name')
        })->count;

        if ($existing && $existing->id != $attribute->id) {
            return FALSE;
        } else {
            return TRUE;
        };
    };

    $form->values({
        id      => $attribute->id,
        name    => $attribute->name,
        value   => $attribute->value,
        created => $attribute->created . ''
    });

    if ($c->forward('submitted') && $c->forward('validate')) {
        $attribute->name($form->field('name'));
        $attribute->value($form->field('value'));
        $attribute->update;
    };
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
