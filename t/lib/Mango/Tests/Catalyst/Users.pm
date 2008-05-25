# $Id$
package Mango::Tests::Catalyst::Users;
use strict;
use warnings;

BEGIN {
    use base 'Mango::Test::Class';

    use Test::More;
    use Path::Class ();
}

sub startup : Test(startup => +2) {
    my $self = shift;
    $self->SUPER::startup(@_);

    use_ok('Mango::Provider::Products');
    use_ok('Mango::Provider::Wishlists');

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
        description => 'ABC Product Description'
    });

    $provider = Mango::Provider::Wishlists->new(
            {
                connection_info => [
                    'dbi:SQLite:'
                      . Path::Class::file( $self->application, 'data', 'mango.db' )
                ]
            }
        );
        my $wishlist = $provider->create({
            user_id => 1,
            name => 'My Wishlist',
            description => 'My Wishlist Description'
        });
        $wishlist->add({
            sku => 'ABC-123',
            quantity => 1,
            description => 'ABC Product Description',
        })
}

sub path {'users'};

sub tests : Test(10) {
    my $self = shift;
    my $m = $self->client;

    ## users not found
    $m->get('http://localhost/users' . $self->path . '/');
    is($m->status, 404);
    $m->content_like(qr/resource.*not found/i);
    $self->validate_markup($m->content);


    ## invalid user not found
    $m->get('http://localhost/' . $self->path . '/claco/');
    is($m->status, 404);
    $m->content_like(qr/user.*not.*found/i);
    $self->validate_markup($m->content);


    ## real user
    $m->get_ok('http://localhost/' . $self->path . '/admin/');
    $m->title_like(qr/admin\'s profile/i);
    $m->content_contains('Admin User');
    $self->validate_markup($m->content);
};

sub tests_create : Test(19) {
    my $self = shift;
    my $m = $self->client;

    ## not logged in
    $m->get_ok('http://localhost/');
    $self->validate_markup($m->content);
    $m->follow_link_ok({text => 'Login'});
    $m->title_like(qr/login/i);
    $m->content_unlike(qr/already logged in/i);
    $m->content_unlike(qr/welcome anonymous/i);
    ok(! $m->find_link(text => 'Logout'));
    $self->validate_markup($m->content);


    ## fail login
    $m->submit_form_ok({
        form_id => 'login',
        fields    => {
            username => 'claco',
            password => 'foo'
        }
    });
    $m->title_like(qr/login/i);
    $m->content_like(qr/username or password.*incorrect/i);
    ok(! $m->find_link(text => 'Logout'));
    $self->validate_markup($m->content);


    ## Sign Up
    $m->follow_link_ok({text => 'Sign Up!'});
    $self->validate_markup($m->content);
    $m->submit_form_ok({
        form_id => 'users_create',
        fields    => {
            username => 'claco',
            password => 'foo',
            confirm_password => 'foo',
            first_name => 'Christopher',
            last_name => 'Laco'
        }
    });
    $m->content_like(qr/welcome christopher/i);
    $m->content_like(qr/profile/i);
    $self->validate_markup($m->content);
}

sub tests_wishlists : Test(16) {
    my $self = shift;
    my $m = $self->client;

    ## view wishlist(s)
    $m->get_ok('http://localhost/' . $self->path . '/admin/');
    $self->validate_markup($m->content);
    $m->title_like(qr/admin\'s profile/i);
    $m->follow_link_ok({text => 'Admin\'s Wishlists'});
    $self->validate_markup($m->content);
    $m->title_like(qr/admin\'s wishlists/i);
    $m->content_contains('My Wishlist');
    $m->content_contains('My Wishlist Description');
    $m->follow_link_ok({text => 'My Wishlist'});
    $self->validate_markup($m->content);
    $m->title_like(qr/my wishlist/i);
    $m->content_contains('ABC-123');
    $m->content_contains('<td align="right">$1.23</td>');


    ## invalid wishlist not found
    $m->get('http://localhost/' . $self->path . '/admin/wishlists/999/');
    is($m->status, 404);
    $m->content_like(qr/wishlist.*not.*found/i);
    $self->validate_markup($m->content);
}

sub test_wishlists_atom_feed : Test(28) {
    my $self = shift;
    my $m = $self->client;

    $m->get_ok('http://localhost/' . $self->path . '/admin/');
    $m->follow_link_ok({text => 'Admin\'s Wishlists'});
    $m->follow_link_ok({text => 'Atom'});
    
    my $content = $m->content;
    $self->validate_feed($content);

    my $feed = XML::Feed->parse(\$content);
    isa_ok($feed, 'XML::Feed');
    is($feed->format, 'Atom');
    is($feed->title, 'Admin User\'s Wishlists');
    is($feed->link, 'http://localhost/' . $self->path . '/admin/wishlists/');
    is($feed->tagline, undef);
    is($feed->description, undef);
    is($feed->author, undef);
    is($feed->language, 'en');
    is($feed->copyright, undef);
    isa_ok($feed->modified, 'DateTime');
    is($feed->generator, undef);

    my @entries = $feed->entries;
    is(scalar @entries, 1);

    my $entry = $entries[0];
    isa_ok($entry, 'XML::Feed::Entry');
    is($entry->title, 'My Wishlist');
    is($entry->link, 'http://localhost/' . $self->path . '/admin/wishlists/1/');
    $m->get_ok($entry->link);
    like($entry->content->body, qr/My Wishlist Description/);
    is($entry->content->type, 'text/html');
    is($entry->summary->body, undef);
    is($entry->category, undef);
    is($entry->author, 'Admin User');
    is($entry->id, 'http://localhost/' . $self->path . '/admin/wishlists/1/');
    isa_ok($entry->issued, 'DateTime');
    isa_ok($entry->modified, 'DateTime');
}

sub test_wishlists_rss_feed : Test(28) {
    my $self = shift;
    my $m = $self->client;

    $m->get_ok('http://localhost/' . $self->path . '/admin/');
    $m->follow_link_ok({text => 'Admin\'s Wishlists'});
    $m->follow_link_ok({text => 'RSS'});
    
    my $content = $m->content;
    $self->validate_feed($content);

    ## fix for now until XML::Feed groks newer dcterms we now emit
    $content =~ s/http:\/\/purl.org\/dc\/terms\//http:\/\/purl.org\/rss\/1.0\/modules\/dcterms\//;

    my $feed = XML::Feed->parse(\$content);
    isa_ok($feed, 'XML::Feed');
    is($feed->format, 'RSS 2.0');
    is($feed->title, 'Admin User\'s Wishlists');
    is($feed->link, 'http://localhost/' . $self->path . '/admin/wishlists/');
    is($feed->tagline, '');
    is($feed->description, '');
    is($feed->author, undef);
    is($feed->language, 'en');
    is($feed->copyright, undef);
    isa_ok($feed->modified, 'DateTime');
    is($feed->generator, undef);

    my @entries = $feed->entries;
    is(scalar @entries, 1);

    my $entry = $entries[0];
    isa_ok($entry, 'XML::Feed::Entry');
    is($entry->title, 'My Wishlist');
    is($entry->link, 'http://localhost/' . $self->path . '/admin/wishlists/1/');
    $m->get_ok($entry->link);
    like($entry->content->body, qr/My Wishlist Description/);
    is($entry->content->type, 'text/html');
    is($entry->summary->body, undef);
    is($entry->category, undef);
    is($entry->author, 'Admin User');
    is($entry->id, 'http://localhost/' . $self->path . '/admin/wishlists/1/');
    isa_ok($entry->issued, 'DateTime');
    isa_ok($entry->modified, 'DateTime');
}

sub test_wishlist_atom_feed : Test(30) {
    my $self = shift;
    my $m = $self->client;

    $m->get_ok('http://localhost/' . $self->path . '/admin/');
    $m->follow_link_ok({text => 'Admin\'s Wishlists'});
    $m->follow_link_ok({text => 'My Wishlist'});
    $m->follow_link_ok({text => 'Atom'});
    
    my $content = $m->content;
    $self->validate_feed($content);

    my $feed = XML::Feed->parse(\$content);
    isa_ok($feed, 'XML::Feed');
    is($feed->format, 'Atom');
    is($feed->title, 'Admin User\'s Wishlists: My Wishlist');
    is($feed->link, 'http://localhost/' . $self->path . '/admin/wishlists/1/');
    is($feed->tagline, undef);
    is($feed->description, undef);
    is($feed->author, undef);
    is($feed->language, 'en');
    is($feed->copyright, undef);
    isa_ok($feed->modified, 'DateTime');
    is($feed->generator, undef);

    my @entries = $feed->entries;
    is(scalar @entries, 1);

    my $entry = $entries[0];
    isa_ok($entry, 'XML::Feed::Entry');
    is($entry->title, 'ABC-123');
    is($entry->link, 'http://localhost/products/ABC-123/');
    $m->get_ok($entry->link);
    like($entry->content->body, qr/\$1\.23/);
    like($entry->content->body, qr//);
    is($entry->content->type, 'text/html');
    is($entry->summary->body, undef);
    is($entry->category, undef);
    is($entry->author, 'Admin User');
    is($entry->id, 'http://localhost/products/ABC-123/');
    isa_ok($entry->issued, 'DateTime');
    isa_ok($entry->modified, 'DateTime');
}

sub test_wishlist_rss_feed : Test(30) {
    my $self = shift;
    my $m = $self->client;

    $m->get_ok('http://localhost/' . $self->path . '/admin/');
    $m->follow_link_ok({text => 'Admin\'s Wishlists'});
    $m->follow_link_ok({text => 'My Wishlist'});
    $m->follow_link_ok({text => 'RSS'});
    
    my $content = $m->content;
    $self->validate_feed($content);

    ## fix for now until XML::Feed groks newer dcterms we now emit
    $content =~ s/http:\/\/purl.org\/dc\/terms\//http:\/\/purl.org\/rss\/1.0\/modules\/dcterms\//;

    my $feed = XML::Feed->parse(\$content);
    isa_ok($feed, 'XML::Feed');
    is($feed->format, 'RSS 2.0');
    is($feed->title, 'Admin User\'s Wishlists: My Wishlist');
    is($feed->link, 'http://localhost/' . $self->path . '/admin/wishlists/1/');
    is($feed->tagline, '');
    is($feed->description, '');
    is($feed->author, undef);
    is($feed->language, 'en');
    is($feed->copyright, undef);
    isa_ok($feed->modified, 'DateTime');
    is($feed->generator, undef);

    my @entries = $feed->entries;
    is(scalar @entries, 1);

    my $entry = $entries[0];
    isa_ok($entry, 'XML::Feed::Entry');
    is($entry->title, 'ABC-123');
    is($entry->link, 'http://localhost/products/ABC-123/');
    $m->get_ok($entry->link);
    like($entry->content->body, qr/\$1\.23/);
    like($entry->content->body, qr/ABC Product Description/);
    is($entry->content->type, 'text/html');
    is($entry->summary->body, undef);
    is($entry->category, undef);
    is($entry->author, 'Admin User');
    is($entry->id, 'http://localhost/products/ABC-123/');
    isa_ok($entry->issued, 'DateTime');
    isa_ok($entry->modified, 'DateTime');
}

sub tests_not_found : Test(4) {
    my $self = shift;
    my $m = $self->client;

    $m->get('http://localhost/users/');
    is( $m->status, 404 );

    $m->get('http://localhost/' . $self->path . '/' . 'bogon/');
    is( $m->status, 404 );    

    $m->get('http://localhost/' . $self->path . '/' . 'admin/');
    is( $m->status, 200 );

    $m->get('http://localhost/' . $self->path . '/' . 'admin/wishlists/bogon');
    is( $m->status, 404 );
}

1;