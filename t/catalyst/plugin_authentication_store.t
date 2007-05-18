#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 77;
    use Mango::Test::Catalyst;

    use_ok('Mango::Catalyst::Plugin::Authentication::Store');
    use_ok('Mango::Exception', ':try');
};

my $c = Mango::Test::Catalyst->context({
    config => {
        connection_info => [Mango::Test->init_schema->dsn]
    },
    stash => {

    }
});

## get a new store instance
my $store = Mango::Catalyst::Plugin::Authentication::Store->new($c->config, $c);
isa_ok($store, 'Mango::Catalyst::Plugin::Authentication::Store');
is($store->config->{'user_model'}, 'Users');
is($store->config->{'user_name_field'}, 'username');
is($store->config->{'role_model'}, 'Roles');
is($store->config->{'role_name_field'}, 'name');
is($store->config->{'profile_model'}, 'Profiles');
is($store->config->{'cart_model'}, 'Carts');


## throw exception when user model doesn't exist
{
    try {
        local $ENV{'LANG'} = 'en';
        local $store->config->{'user_model'} = 'Crap';
        $store->anonymous_user($c);

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/model requested 'Crap' could not be found/i, 'user model not found');
    } otherwise {
        fail('Other exception thrown');
    };
};


## get an anonymous user
{
    my $user = $store->anonymous_user($c);
    isa_ok($user, 'Mango::Catalyst::Plugin::Authentication::AnonymousUser');
    is_deeply($user->config, $store->config);

    ## user
    my $object = $user->get_object;
    isa_ok($object, 'Mango::User');
    is($object->id, '0E0');
    is($object->username, 'anonymous');
    is($object->password, undef);
    is($user->id, '0E0');
    is($user->username, 'anonymous');
    is($user->password, undef);
    is($user->get('id'), '0E0');
    is($user->get('username'), 'anonymous');
    is($user->get('password'), undef);

    ## profile
    my $profile = $user->profile;
    isa_ok($profile, 'Mango::Profile');
    is($profile->id, '0E0');
    is($profile->first_name, 'Anonymous');
    is($profile->last_name, 'User');

    ## roles
    my @roles = $user->roles;
    is(scalar @roles, 0);

    ## cart (existing)
    local $c->session->{'__mango_cart_id'} = 1;
    is($user->_cart, undef);
    my $cart = $user->cart;
    isa_ok($cart, 'Mango::Cart');
    is($cart->id, 1);
    is($cart->count, 2);
    is($cart->items->first->sku, 'ABC-123');
    is($c->model('Carts')->search->count, 2);
    isa_ok($user->_cart, 'Mango::Cart');
    is($user->_cart->id, 1);

    ## cart (new)
    local $c->session->{'__mango_cart_id'} = undef;
    $user->_cart(undef);
    $cart = $user->cart;
    isa_ok($cart, 'Mango::Cart');
    is($cart->id, 3);
    is($cart->count, 0);
    is($cart->items->first, undef);
    is($c->model('Carts')->search->count, 3);
    isa_ok($user->_cart, 'Mango::Cart');
    is($user->_cart->id, 3);
};


## get a regular user from the Users model
{
    my $user = $store->find_user({
        username => 'test1'
    }, $c);
    isa_ok($user, 'Mango::Catalyst::Plugin::Authentication::User');
    is_deeply($user->config, $store->config);

    ## user
    my $object = $user->get_object;
    isa_ok($object, 'Mango::User');
    is($object->id, 1);
    is($object->username, 'test1');
    is($object->password, 'password1');
    is($user->id, 1);
    is($user->username, 'test1');
    is($user->password, 'password1');
    is($user->get('id'), 1);
    is($user->get('username'), 'test1');
    is($user->get('password'), 'password1');

    ## profile
    my $profile = $user->profile;
    isa_ok($profile, 'Mango::Profile');
    is($profile->id, 1);
    is($profile->first_name, 'First1');
    is($profile->last_name, 'Last1');

    ## roles
    my @roles = $user->roles;
    is(scalar @roles, 2);
    is($roles[0], 'role1');
    is($roles[1], 'role2');

    ## cart (existing)
    local $c->session->{'__mango_cart_id'} = 1;
    is($user->_cart, undef);
    my $cart = $user->cart;
    isa_ok($cart, 'Mango::Cart');
    is($cart->id, 1);
    is($cart->count, 2);
    is($cart->items->first->sku, 'ABC-123');
    is($c->model('Carts')->search->count, 3);
    isa_ok($user->_cart, 'Mango::Cart');
    is($user->_cart->id, 1);

    ## cart (new)
    local $c->session->{'__mango_cart_id'} = undef;
    $user->_cart(undef);
    $cart = $user->cart;
    isa_ok($cart, 'Mango::Cart');
    is($cart->id, 4);
    is($cart->count, 0);
    is($cart->items->first, undef);
    is($c->model('Carts')->search->count, 4);
    isa_ok($user->_cart, 'Mango::Cart');
    is($user->_cart->id, 4);
};
