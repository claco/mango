package Mango::Catalyst::Controller::Products;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Controller/;
    use Mango ();
    use Path::Class::Dir ();

    __PACKAGE__->config(
        resource_name  => 'mango/products',
        form_directory => Path::Class::Dir->new(Mango->share, 'forms', 'products')
    );
};

sub index : Template('products/index') {
    my ($self, $c) = @_;
    my $tags = $c->model('Products')->tags({
        
    }, {
        order_by => 'tag.name'
    });

    $c->stash->{'tags'} = $tags;

    return;
};

sub tags : Local Template('products/index') {
    my ($self, $c, @tags) = @_;

    return unless scalar @tags;

    my $products = $c->model('Products')->search({
        tags => \@tags
    }, {
        page => $self->current_page,
        rows => $self->entries_per_page
    });
    my $pager = $products->pager;

    $c->stash->{'products'} = $products;
    $c->stash->{'pager'} = $pager;

    return;
};

1;
__END__

=head1 NAME

Mango::Catalyst::Controller::Products - Catalyst controller for displaying
products.

=head1 DESCRIPTION

Mango::Catalyst::Controller::products provides the web interface for
displaying products.

=head1 ACTIONS

=head2 index : /

Displays the main product page.

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
