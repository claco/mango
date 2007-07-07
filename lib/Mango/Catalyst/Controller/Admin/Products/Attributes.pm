package Mango::Catalyst::Controller::Admin::Products::Attributes;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller::Form/;
    use Set::Scalar ();
    use Catalyst::Utils ();
};

sub index : PathPart('attributes') Chained('/admin/products/load') Args(0) {
    my ($self, $c) = @_;

    my $product = $c->stash->{'product'};
    my $page = $c->request->param('page') || 1;
    my $attributes = $product->attributes(undef, {
        page => $page,
        rows => 10
    });

    $c->stash->{'attributes'} = $attributes;
    $c->stash->{'pager'} = $attributes->pager;
};

sub load : PathPart('attributes') Chained('/admin/products/load') CaptureArgs(1) {
    my ($self, $c, $id) = @_;
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
    my $product = $c->stash->{'product'};
    my $form = $self->form;

    $form->unique('name', sub {
        return !$product->attributes({
            name => $form->field('name')
        })->count;
    });

    if ($self->submitted && $self->validate->success) {
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
    my $attribute = $c->stash->{'attribute'};
    my $form = $self->form;

    $form->unique('name', sub {
        if ($attribute->name eq $form->field('name')) {
            return 1;
        };
        my $existing = $c->stash->{'product'}->attributes({
            name => $form->field('name')
        })->count;

        if ($existing && $existing->id != $attribute->id) {
            return;
        } else {
            return 1;
        };
    });

    $form->values({
        id      => $attribute->id,
        name    => $attribute->name,
        value   => $attribute->value,
        created => $attribute->created . ''
    });

    if ($self->submitted && $self->validate->success) {
        $attribute->name($form->field('name'));
        $attribute->value($form->field('value'));
        $attribute->update;
    };
};

1;
__END__
