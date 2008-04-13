# $Id$
package Mango::Catalyst::Controller::Admin::Products::Attributes;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
    use Set::Scalar ();
    use Mango       ();
    use Path::Class ();

    __PACKAGE__->config(
        resource_name  => 'mango/admin/products/attributes',
        form_directory => Path::Class::Dir->new(
            Mango->share, 'forms', 'admin', 'products', 'attributes'
        )
    );
}

sub index : PathPart('attributes') Chained('../load') Args(0)
  Template('admin/products/attributes/index') {
    my ( $self, $c ) = @_;
    my $product    = $c->stash->{'product'};
    my $page       = $c->request->param('page') || 1;
    my $attributes = $product->attributes(
        undef,
        {
            page => $page,
            rows => 10
        }
    );

    $c->stash->{'attributes'}  = $attributes;
    $c->stash->{'pager'}       = $attributes->pager;
    $c->stash->{'delete_form'} = $self->form('delete');

    return;
}

sub load : PathPart('attributes') Chained('../load') CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    my $attribute =
      $c->stash->{'product'}->attributes( { id => $id } )->first;

    if ($attribute) {
        $c->stash->{'attribute'} = $attribute;
    } else {
        $c->response->status(404);
        $c->detach;
    }

    return;
}

sub create : PathPart('attributes/create') Chained('../load') Args(0)
  Template('admin/products/attributes/create') {
    my ( $self, $c ) = @_;
    my $product = $c->stash->{'product'};
    my $form    = $self->form;

    $form->unique(
        'name',
        sub {
            return !$product->attributes( { name => $form->field('name') } )
              ->count;
        }
    );

    if ( $self->submitted && $self->validate->success ) {
        my $attribute = $product->add_attribute(
            {
                name  => $form->field('name'),
                value => $form->field('value')
            }
        );

        $c->response->redirect(
            $c->uri_for(
                '/admin/products', $product->id,
                'attributes',      $attribute->id,
                'edit/'
            )
        );
    }

    return;
}

sub edit : PathPart('edit') Chained('load') Args(0)
  Template('admin/products/attributes/edit') {
    my ( $self, $c ) = @_;
    my $attribute = $c->stash->{'attribute'};
    my $form      = $self->form;

    $form->unique(
        'name',
        sub {
            if ( $attribute->name eq $form->field('name') ) {
                return 1;
            }
            my $existing =
              $c->stash->{'product'}
              ->attributes( { name => $form->field('name') } )->count;

            if ( $existing && $existing->id != $attribute->id ) {
                return;
            } else {
                return 1;
            }
        }
    );

    $form->values(
        {
            id      => $attribute->id,
            name    => $attribute->name,
            value   => $attribute->value,
            created => $attribute->created . '',
            updated => $attribute->updated . ''
        }
    );

    if ( $self->submitted && $self->validate->success ) {
        $attribute->name( $form->field('name') );
        $attribute->value( $form->field('value') );
        $attribute->update;

        $form->values( { updated => $attribute->updated . '' } );
    }

    return;
}

sub delete : Chained('load') PathPart Args(0)
  Template('admin/products/attributes/delete') {
    my ( $self, $c ) = @_;
    my $product   = $c->stash->{'product'};
    my $attribute = $c->stash->{'attribute'};
    my $form      = $self->form;

    if ( $self->submitted && $self->validate->success ) {
        if ( $form->field('id') == $attribute->id ) {

            $attribute->destroy;

            $c->response->redirect(
                $c->uri_for( '/admin/products', $product->id, 'attributes/' )
            );
        } else {
            $c->stash->{'errors'} = ['ID_MISTMATCH'];
        }
    }

    return;
}

1;
__END__

=head1 NAME

Mango::Catalyst::Controller::Admin::Products::Attributes - Catalyst controller for product attribute admin

=head1 SYNOPSIS

    package MyApp::Controllers::Admin::Products::Attributes;
    use base qw/Mango::Catalyst::Controllers::Admin::Products::Attributes/;

=head1 DESCRIPTION

Mango::Catalyst::Controller::Admin::Products::Attributes is the controller
used to edit a specific products attributes.

=head1 ACTIONS

=head2 index : products/<id>/attributes

Displays the list of attributes for a specific product.

=head2 create : products/<id>/attributes/create

Adds an attribute to the given product.

=head2 delete : products/<id>/attributes/<id>/delete

Deletes the specified attribute form the current product.

=head2 edit : products/<id>/attributes/<id>/edit

Updates the specified attribute.

=head2 load : products/<id>/attributes/<id>

Loads a specific products attribute.

=head1 SEE ALSO

L<Mango::Catalyst::Controller::Admin::Products>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
