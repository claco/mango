# $Id$
package Mango::Tests::Catalyst::Products;
use strict;
use warnings;

BEGIN {
    use base 'Mango::Test::Class';

    use Test::More;
    use Path::Class ();
}

sub startup : Test(startup => +1) {
    my $self = shift;
    $self->SUPER::startup(@_);

    use_ok('Mango::Provider::Products');

    my $provider = Mango::Provider::Products->new(
        {
            connection_info => [
                'dbi:SQLite:'
                  . Path::Class::file( $self->application, 'data', 'mango.db' )
            ]
        }
    );
    $provider->create({
        sku => 'ABC-123',
        price => 1.23,
        name => 'ABC Product',
        description => 'ABC Product Description',
        tags => [qw/tag1 tag3/],
        attributes => [
            {name => 'foo', value => 'bar'}
        ]
    });
    $provider->create({
        sku => 'DEF-345',
        price => 10.00,
        name => 'DEF Product',
        description => 'DEF Product Description',
        tags => [qw/tag2 tag3/]
    });
    $provider->create({
        sku => 'GHI-666',
        price => 125.32,
        name => 'GHI Product',
        description => 'GHI Product Description',
        tags => [qw/tag1 tag5/]
    });
}

sub path {'products'};

sub tests : Test(64) {
    my $self = shift;
    my $m = $self->client;

    ## cart is empty
    $m->get_ok('http://localhost/');
    $m->follow_link_ok({text => 'Cart'});
    $m->title_like(qr/cart/i);
    $m->content_like(qr/cart is empty/i);


    ## view product index tags
    $m->follow_link_ok({text => 'Products'});
    $m->title_like(qr/products/i);
    is($m->uri->path, '/' . $self->path . '/');
    ok($m->find_link(text => 'tag1'));
    ok($m->find_link(text => 'tag2'));
    ok($m->find_link(text => 'tag3'));
    ok($m->find_link(text => 'tag5'));


    ## follow the tag cloud
    $m->follow_link_ok({text => 'tag5'});
    ok($m->find_link(text => 'tag1'));
    ok(!$m->find_link(text => 'tag2'));
    ok(!$m->find_link(text => 'tag3'));
    ok(!$m->find_link(text => 'tag5'));
    $m->content_lacks('ABC-123');
    $m->content_lacks('DEF-345');
    $m->content_contains('GHI-666');
    $m->content_contains('GHI Product Description');
    $m->content_contains('$125.32');
    $m->submit_form_ok({
        form_name => 'cart_add',
        fields    => {
                quantity => 2
        }
    });
    $m->title_like(qr/cart/i);
    $m->content_contains('<td align="left">GHI-666</td>');
    $m->content_contains('<td align="left">GHI Product Description</td>');
    $m->content_contains('<td align="right">$125.32</td>');
    $m->content_contains('<td align="right">$250.64</td>');


    ## follow the tag cloud two deep
    $m->follow_link_ok({text => 'Products'});
    $m->follow_link_ok({text => 'tag3'});
    ok($m->find_link(text => 'tag1'));
    ok($m->find_link(text => 'tag2'));
    ok(!$m->find_link(text => 'tag3'));
    ok(!$m->find_link(text => 'tag5'));
    $m->content_lacks('GHI-666');
    $m->content_contains('ABC-123');
    $m->content_contains('ABC Product Description');
    $m->content_contains('$1.23');
    $m->content_contains('DEF-345');
    $m->content_contains('DEF Product Description');
    $m->content_contains('$10.00');
    $m->follow_link_ok({text => 'tag2'});
    ok(!$m->find_link(text => 'tag1'));
    ok(!$m->find_link(text => 'tag2'));
    ok(!$m->find_link(text => 'tag3'));
    ok(!$m->find_link(text => 'tag5'));
    $m->content_lacks('GHI-666');
    $m->content_lacks('ABC-123');
    $m->content_contains('DEF-345');
    $m->content_contains('DEF Product Description');
    $m->content_contains('$10.00');


    ## product view
    $m->follow_link_ok({text => 'Products'});
    $m->follow_link_ok({text => 'tag1'});
    $m->follow_link_ok({text => 'ABC Product'});
    $m->content_contains('ABC-123');
    $m->content_contains('ABC Product Description');
    $m->content_contains('$1.23');
    $m->content_contains('foo: bar');
    $m->submit_form_ok({
        form_name => 'cart_add',
        fields    => {
                quantity => 3
        }
    });
    $m->title_like(qr/cart/i);
    $m->content_contains('<td align="left">ABC-123</td>');
    $m->content_contains('<td align="left">ABC Product Description</td>');
    $m->content_contains('<td align="right">$1.23</td>');
    $m->content_contains('<td align="right">$3.69</td>');
};

sub tests_not_found : Test(2) {
    my $self = shift;
    my $m = $self->client;

    $m->get('http://localhost/products/');
    if ($self->path eq 'products') {
        is( $m->status, 200 );
    } else {
        is( $m->status, 404 );
    }

    $m->get('http://localhost/' . $self->path . '/' . 'bogon/');
    is( $m->status, 404 );
}

1;
