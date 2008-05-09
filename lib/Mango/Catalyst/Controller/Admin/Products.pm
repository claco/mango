# $Id$
package Mango::Catalyst::Controller::Admin::Products;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
    use Set::Scalar ();
    use Mango       ();
    use Path::Class ();

    __PACKAGE__->config(
        resource_name => 'mango/admin/products',
        form_directory =>
          Path::Class::Dir->new( Mango->share, 'forms', 'admin', 'products' )
    );
}

sub index : Template('admin/products/index') {
    my ( $self, $c ) = @_;
    my $page = $c->request->param('page') || 1;
    my $products = $c->model('Products')->search(
        undef,
        {
            page => $page,
            rows => 10
        }
    );

    $c->stash->{'products'}    = $products;
    $c->stash->{'pager'}       = $products->pager;
    $c->stash->{'delete_form'} = $self->form('delete');

    return;
}

sub load : Chained('/') PathPrefix CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    my $product = $c->model('Products')->get_by_id($id);

    if ($product) {
        $c->stash->{'product'} = $product;
    } else {
        $c->response->status(404);
        $c->detach;
    }

    return;
}

sub create : Local Template('admin/products/create') {
    my ( $self, $c ) = @_;
    my $form = $self->form;

    $form->unique(
        'sku',
        sub {
            return !$c->model('Products')
              ->search( { sku => $form->field('sku') } )->count;
        }
    );

    if ( $self->submitted && $self->validate->success ) {
        my $product = $c->model('Products')->create(
            {
                sku         => $form->field('sku'),
                name        => $form->field('name'),
                description => $form->field('description'),
                price       => $form->field('price')
            }
        );

        if ( my $tags = $form->field('tags') ) {
            $product->add_tags( split /,\s*/, $tags );
        }

        $c->response->redirect(
            $c->uri_for( $self->action_for('edit'), [ $product->id ] )
              . '/' );
    }

    return;
}

sub edit : Chained('load') PathPart Args(0) Template('admin/products/edit') {
    my ( $self, $c ) = @_;
    my $product = $c->stash->{'product'};
    my @tags    = $product->tags;
    my $form    = $self->form;

    $form->unique(
        'sku',
        sub {
            if ( $product->sku eq $form->field('sku') ) {
                return 1;
            }
            my $existing =
              $c->model('Products')->search( { sku => $form->field('sku') } )
              ->first;

            if ( $existing && $existing->id != $product->id ) {
                return;
            } else {
                return 1;
            }
        }
    );

    $form->values(
        {
            id          => $product->id,
            sku         => $product->sku,
            name        => $product->name,
            description => $product->description,
            price       => $product->price->value,
            tags        => join( ', ', map { $_->name } @tags ),
            created     => $product->created . '',
            updated     => $product->updated . ''
        }
    );

    if ( $self->submitted && $self->validate->success ) {
        $product->name( $form->field('name') );
        $product->sku( $form->field('sku') );
        $product->description( $form->field('description') );
        $product->price( $form->field('price') );
        $product->update;

        $form->values( { updated => $product->updated . '' } );

        if ( my $tags = $form->field('tags') ) {
            my $current_tags = Set::Scalar->new( map { $_->name } @tags );
            my $selected_tags = Set::Scalar->new( split /,\s*/, $tags );
            my $deleted_tags  = $current_tags - $selected_tags;
            my $added_tags    = $selected_tags - $current_tags;

            if ( $added_tags->size ) {
                $product->add_tags( $added_tags->members );
            }

            if ( $deleted_tags->size ) {
                $product->delete_tags(
                    { name => [ $deleted_tags->members ] } );
            }
        }
    }

    return;
}

sub delete : Chained('load') PathPart Args(0)
  Template('admin/products/delete') {
    my ( $self, $c ) = @_;
    my $form    = $self->form;
    my $product = $c->stash->{'product'};

    if ( $self->submitted && $self->validate->success ) {
        if ( $form->field('id') == $product->id ) {

            $product->destroy;

            $c->response->redirect(
                $c->uri_for( $self->action_for('index') ) . '/' );
        } else {
            $c->stash->{'errors'} = ['ID_MISTMATCH'];
        }
    }

    return;
}

1;
__END__

=head1 NAME

Mango::Catalyst::Controller::Admin::Products - Catalyst controller for product admin

=head1 SYNOPSIS

    package MyApp::Controllers::Admin::Products;
    use base qw/Mango::Catalyst::Controllers::Admin::Products/;

=head1 DESCRIPTION

Mango::Catalyst::Controller::Admin::Products is the controller
used to edit products.

=head1 ACTIONS

=head2 index : /admin/products/

Displays the list of products.

=head2 create : /admin/products/create/

Creates a new product.

=head2 delete : /admin/products/<id>/delete/

Deletes the specified product.

=head2 edit : /admin/products/<id>/edit/

Updates the specified product.

=head2 load : /admin/products/<id>/

Loads a specific product.

=head1 SEE ALSO

L<Mango::Catalyst::Model::Products>, L<Mango::Provider::Products>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
