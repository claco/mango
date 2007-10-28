package Mango::Catalyst::Controller::Admin::Products::Attributes;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller::Form/;
    use Set::Scalar ();
    use Mango ();
    use Path::Class ();
    
    __PACKAGE__->form_directory(
        Path::Class::Dir->new(Mango->share, 'forms', 'admin', 'products', 'attributes')
    );
};

sub COMPONENT {
    my $class = shift;
    my $self = $class->NEXT::COMPONENT(@_);
    $_[0]->config->{'mango'}->{'controllers'}->{'admin_products_attributes'} = $class;

    return $self;
};

sub index : PathPart('attributes') Chained('/admin/products/load') Args(0) Template('admin/products/attributes/index') {
    my ($self, $c) = @_;

    my $product = $c->stash->{'product'};
    my $page = $c->request->param('page') || 1;
    my $attributes = $product->attributes(undef, {
        page => $page,
        rows => 10
    });

    $c->stash->{'attributes'} = $attributes;
    $c->stash->{'pager'} = $attributes->pager;
    $c->stash->{'delete_form'} = $self->form('delete');
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

sub create : PathPart('attributes/create') Chained('/admin/products/load') Args(0) Template('admin/products/attributes/create') {
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

sub edit : PathPart('edit') Chained('load') Args(0) Template('admin/products/attributes/edit') {
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
        created => $attribute->created . '',
        updated => $attribute->updated . ''
    });

    if ($self->submitted && $self->validate->success) {
        $attribute->name($form->field('name'));
        $attribute->value($form->field('value'));
        $attribute->update;
        
        $form->values({
            updated     => $attribute->updated . ''
        });
    };
};

sub delete : Chained('load') PathPart Args(0) Template('admin/products/attributes/delete') {
    my ($self, $c) = @_;
    my $product = $c->stash->{'product'};
    my $attribute = $c->stash->{'attribute'};
    my $form = $self->form;

    if ($self->submitted && $self->validate->success) {
        if ($form->field('id') == $attribute->id) {

            $attribute->destroy;

            $c->response->redirect(
                $c->uri_for('/admin/products', $product->id, 'attributes/')
            );
        } else {
            $c->stash->{'errors'} = ['ID_MISTMATCH'];
        };
    };
};

1;
__END__

=head1 NAME

Mango::Tag - Module representing a [folksonomy] tag

=head1 SYNOPSIS

    my $tags = $product->tags;
    
    while (my $tag = %tags->next) {
        print $tag->name;
    };

=head1 DESCRIPTION

Mango::Tag represents a tag assigned to products.

=head1 METHODS

=head2 count

Returns the number of instances this tag.

B<This is not currently implemented and always returns 0>.

=head2 created

Returns the date and time in UTC the tag was created as a DateTime
object.

    print $user->created;

=head2 destroy

B<This is not currently implemented>.

=head2 id

Returns the id of the current tag.

    print $tag->id;

=head2 name

=over

=item Arguments: $name

=back

Gets/sets the name of the current tag.

    print $tag->name;

=head2 updated

Returns the date and time in UTC the tag was last updated as a DateTime
object.

    print $user->updated;

=head1 SEE ALSO

L<Mango::Object>, L<Mango::Product>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
