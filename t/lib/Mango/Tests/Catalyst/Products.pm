# $Id$
package Mango::Tests::Catalyst::Products;
use strict;
use warnings;

BEGIN {
    use base 'Mango::Test::Class';

    use Test::More;
    use Path::Class ();
    use XML::Feed   ();
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

sub test_atom_feed : Tests(42) {
    my $self = shift;
    my $m = $self->client;

    $m->get_ok('http://localhost/');
    $m->follow_link_ok({text => 'Products'});
    $m->follow_link_ok({text => 'tag1'});
    $m->follow_link_ok({text => 'Atom'});
    
    my $content = $m->content;
    my $feed = XML::Feed->parse(\$content);
    isa_ok($feed, 'XML::Feed');
    is($feed->format, 'Atom');
    is($feed->title, 'Products: tag1');
    is($feed->link, 'http://localhost/' . $self->path . '/tags/tag1/');
    is($feed->tagline, undef);
    is($feed->description, undef);
    is($feed->author, undef);
    is($feed->language, 'en');
    is($feed->copyright, undef);
    isa_ok($feed->modified, 'DateTime');
    is($feed->generator, undef);

    my @entries = $feed->entries;
    is(scalar @entries, 2);

    my $entry = $entries[0];
    isa_ok($entry, 'XML::Feed::Entry');
    is($entry->title, 'ABC-123');
    is($entry->link, 'http://localhost/' . $self->path . '/ABC-123/');
    $m->get_ok($entry->link);
    like($entry->content->body, qr/\$1\.23/);
    like($entry->content->body, qr/ABC Product Description/);
    is($entry->content->type, 'text/html');
    is($entry->summary->body, undef);
    is($entry->category, undef);
    is($entry->author, undef);
    is($entry->id, 1);
    isa_ok($entry->issued, 'DateTime');
    isa_ok($entry->modified, 'DateTime');

    $entry = $entries[1];
    isa_ok($entry, 'XML::Feed::Entry');
    is($entry->title, 'GHI-666');
    is($entry->link, 'http://localhost/' . $self->path . '/GHI-666/');
    $m->get_ok($entry->link);
    like($entry->content->body, qr/\$125\.32/);
    like($entry->content->body, qr/GHI Product Description/);
    is($entry->content->type, 'text/html');
    is($entry->summary->body, undef);
    is($entry->category, undef);
    is($entry->author, undef);
    is($entry->id, 3);
    isa_ok($entry->issued, 'DateTime');
    isa_ok($entry->modified, 'DateTime');
}

sub test_rss_feed : Tests(42) {
    my $self = shift;
    my $m = $self->client;

    $m->get_ok('http://localhost/');
    $m->follow_link_ok({text => 'Products'});
    $m->follow_link_ok({text => 'tag1'});
    $m->follow_link_ok({text => 'RSS'});
    
    my $content = $m->content;
    my $feed = XML::Feed->parse(\$content);
    isa_ok($feed, 'XML::Feed');
    is($feed->format, 'RSS 2.0');
    is($feed->title, 'Products: tag1');
    is($feed->link, 'http://localhost/' . $self->path . '/tags/tag1/');
    is($feed->tagline, '');
    is($feed->description, '');
    is($feed->author, undef);
    is($feed->language, 'en');
    is($feed->copyright, undef);
    is($feed->modified, undef);
    is($feed->generator, undef);

    my @entries = $feed->entries;
    is(scalar @entries, 2);

    my $entry = $entries[0];
    isa_ok($entry, 'XML::Feed::Entry');
    is($entry->title, 'ABC-123');
    is($entry->link, 'http://localhost/' . $self->path . '/ABC-123/');
    $m->get_ok($entry->link);
    like($entry->content->body, qr/\$1\.23/);
    like($entry->content->body, qr/ABC Product Description/);
    is($entry->content->type, 'text/html');
    is($entry->summary->body, undef);
    is($entry->category, undef);
    is($entry->author, undef);
    is($entry->id, 'http://localhost/' . $self->path . '/ABC-123/');
    isa_ok($entry->issued, 'DateTime');
    isa_ok($entry->modified, 'DateTime');

    $entry = $entries[1];
    isa_ok($entry, 'XML::Feed::Entry');
    is($entry->title, 'GHI-666');
    is($entry->link, 'http://localhost/' . $self->path . '/GHI-666/');
    $m->get_ok($entry->link);
    like($entry->content->body, qr/\$125\.32/);
    like($entry->content->body, qr/GHI Product Description/);
    is($entry->content->type, 'text/html');
    is($entry->summary->body, undef);
    is($entry->category, undef);
    is($entry->author, undef);
    is($entry->id, 'http://localhost/' . $self->path . '/GHI-666/');
    isa_ok($entry->issued, 'DateTime');
    isa_ok($entry->modified, 'DateTime');
}

sub tests : Test(75) {
    my $self = shift;
    my $m = $self->client;

    ## cart is empty
    $m->get_ok('http://localhost/');
    $self->validate_markup($m->content);
    $m->follow_link_ok({text => 'Cart'});
    $m->title_like(qr/cart/i);
    $m->content_like(qr/cart is empty/i);
    $self->validate_markup($m->content);


    ## view product index tags
    $m->follow_link_ok({text => 'Products'});
    $m->title_like(qr/products/i);
    is($m->uri->path, '/' . $self->path . '/');
    ok($m->find_link(text => 'tag1'));
    ok($m->find_link(text => 'tag2'));
    ok($m->find_link(text => 'tag3'));
    ok($m->find_link(text => 'tag5'));
    $self->validate_markup($m->content);


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
    $self->validate_markup($m->content);
    $m->submit_form_ok({
        form_id => 'cart_add_3',
        fields    => {
                quantity => 2
        }
    });
    $m->title_like(qr/cart/i);
    $m->content_contains('<td align="left">GHI-666</td>');
    $m->content_contains('<td align="left">GHI Product Description</td>');
    $m->content_contains('<td align="right">$125.32</td>');
    $m->content_contains('<td align="right">$250.64</td>');
    $self->validate_markup($m->content);


    ## follow the tag cloud two deep
    $m->follow_link_ok({text => 'Products'});
    $self->validate_markup($m->content);
    $m->follow_link_ok({text => 'tag3'});
    $self->validate_markup($m->content);
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
    $self->validate_markup($m->content);
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
    $self->validate_markup($m->content);
    $m->follow_link_ok({text => 'tag1'});
    $self->validate_markup($m->content);
    $m->follow_link_ok({text => 'ABC Product'});
    $self->validate_markup($m->content);
    $m->content_contains('ABC-123');
    $m->content_contains('ABC Product Description');
    $m->content_contains('$1.23');
    $m->content_contains('foo: bar');
    $m->submit_form_ok({
        form_id => 'cart_add',
        fields    => {
                quantity => 3
        }
    });
    $m->title_like(qr/cart/i);
    $m->content_contains('<td align="left">ABC-123</td>');
    $m->content_contains('<td align="left">ABC Product Description</td>');
    $m->content_contains('<td align="right">$1.23</td>');
    $m->content_contains('<td align="right">$3.69</td>');
    $self->validate_markup($m->content);
};

sub test_not_found : Test(4) {
    my $self = shift;
    my $m = $self->client;

    $m->get('http://localhost/products/');
    if ($self->path eq 'products') {
        is( $m->status, 200 );
    } else {
        is( $m->status, 404 );
    }
    $self->validate_markup($m->content);

    $m->get('http://localhost/' . $self->path . '/' . 'bogon/');
    is( $m->status, 404 );
    $self->validate_markup($m->content);
}

1;
