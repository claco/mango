#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 14;
    use Path::Class 'file';

    use_ok('Mango::Provider::Products');

    my $temp = Mango::Test->mk_app;
    my $provider = Mango::Provider::Products->new({
        connection_info => ['dbi:SQLite:' . file(
            $temp, 'data', 'mango.db'
        )]
    });
    
    diag( $provider->schema->resultset('Users')->search->count );
    diag( $provider->schema->resultset('Products')->search->count );
    my $product = $provider->create({
        sku => 'ABC-123',
        price => 1.23,
        description => 'ABC Product'
    });
    diag( $provider->schema->resultset('Products')->search->count );

    undef $provider;
};


{
    my $m = Test::WWW::Mechanize::Catalyst->new;

    ## cart is empty
    $m->get_ok('http://localhost/');
    $m->follow_link_ok({text => 'Cart'});
    $m->title_like(qr/cart/i);
    $m->content_like(qr/cart is empty/i);

    ## add missing part/sku
    $m->follow_link_ok({text => 'Products'});
    $m->title_like(qr/products/i);
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_name => 'cart_add',
            fields    => {
                sku => 'NOT-FOUND',
                quantity => 2
            }
        });
    };
    $m->title_like(qr/cart/i);
    $m->content_like(qr/part.*could not be found/i);

    ## add existing part/sku
    $m->follow_link_ok({text => 'Products'});
    $m->title_like(qr/products/i);
    {
        local $SIG{__WARN__} = sub {};
        $m->submit_form_ok({
            form_name => 'cart_add',
            fields    => {
                sku => 'ABC-123',
                quantity => 2
            }
        });
    };
    $m->title_like(qr/cart/i);
    warn $m->content;
};
