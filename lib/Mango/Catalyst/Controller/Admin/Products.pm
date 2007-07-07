package Mango::Catalyst::Controller::Admin::Products;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller::Form/;
    use Set::Scalar ();
};

sub _parse_PathPrefix_attr {
    my ($self, $c, $name, $value) = @_;

    return PathPart => $self->path_prefix;
};

sub index : Private {
    my ($self, $c) = @_;
    my $page = $c->request->param('page') || 1;
    my $products = $c->model('Products')->search(undef, {
        page => $page,
        rows => 10
    });

    $c->stash->{'products'} = $products;
    $c->stash->{'pager'} = $products->pager;
};

sub load : Chained('/') PathPrefix CaptureArgs(1) {
    my ($self, $c, $id) = @_;
    my $product = $c->model('Products')->get_by_id($id);

    if ($product) {
        $c->stash->{'product'} = $product;
    } else {
        $c->response->status(404);
        $c->detach;
    };
};

sub create : Local {
    my ($self, $c) = @_;
    my $form = $self->form;

    $form->unique('sku', sub {
        return !$c->model('Products')->search({
            sku => $form->field('sku')
        })->count;
    });

    if ($self->submitted && $self->validate->success) {
        my $product = $c->model('Products')->create({
            sku => $form->field('sku'),
            name => $form->field('name'),
            description => $form->field('description'),
            price => $form->field('price')
        });

        if (my $tags = $form->field('tags')) {
            $product->add_tags(split /,\s*/, $tags);
        };

        $c->response->redirect(
            $c->uri_for('/', $self->path_prefix, $product->id, 'edit/')
        );
    };
};

sub edit : Chained('load') PathPart Args(0) {
    my ($self, $c) = @_;
    my $product = $c->stash->{'product'};
    my @tags = $product->tags;
    my $form = $self->form;

    $form->unique('sku', sub {
        if ($product->sku eq $form->field('sku')) {
            return 1;
        };
        my $existing = $c->model('Products')->search({
            sku => $form->field('sku')
        });

        if ($existing && $existing->id != $product->id) {
            return;
        } else {
            return 1;
        };
    });

    $form->values({
        id          => $product->id,
        sku         => $product->sku,
        name        => $product->name,
        description => $product->description,
        price       => $product->price->value,
        tags        => join(', ', map {$_->name} @tags),
        created     => $product->created . ''
    });

    if ($self->submitted && $self->validate->success) {
        $product->name($form->field('name'));
        $product->sku($form->field('sku'));
        $product->description($form->field('description'));
        $product->price($form->field('price'));
        $product->update;

        if (my $tags = $form->field('tags')) {
            my $current_tags = Set::Scalar->new(map {$_->name} @tags);
            my $selected_tags = Set::Scalar->new(split /,\s*/, $tags);
            my $deleted_tags = $current_tags - $selected_tags;
            my $added_tags = $selected_tags - $current_tags;

            if ($added_tags->size) {
                $product->add_tags($added_tags->members);
            };

            if ($deleted_tags->size) {
                $product->delete_tags({
                    name => [$deleted_tags->members]
                });
            };
        };
    };
};

1;
__END__
