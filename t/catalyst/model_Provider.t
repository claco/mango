#!perl -wT
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 14;
    use Mango::Test::Catalyst;

    use_ok('Mango::Catalyst::Model::Provider');
    use_ok('Mango::Exception', ':try');
};


## throw exception when no provider class is specified
{
    try {
        local $ENV{'LANG'} = 'en';

        Mango::Test::Catalyst->context->model('Provider');

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/no provider class/i, 'no provider class');
    } otherwise {
        fail('Other exception thrown');
    };
};


## throw exception when provider class can't be loaded
{
    Mango::Catalyst::Model::Provider->config(
        provider_class => 'JunkClassNoWorky'
    );

    try {
        local $ENV{'LANG'} = 'en';

        Mango::Test::Catalyst->context->model('Provider');

        fail('no exception thrown');
    } catch Mango::Exception with {
        pass('Argument exception thrown');
        like(shift, qr/provider.*could not be loaded/i, 'provider class not loaded');
    } otherwise {
        fail('Other exception thrown');
    };
};


## get provider class and context connection and load it
{
    Mango::Catalyst::Model::Provider->config(
        provider_class => 'Mango::Provider::DBIC'
    );

    my $c = Mango::Test::Catalyst->context({
        config => {
            connection_info => ['dsn', 'user', 'password']
        }
    });
    my $model = $c->model('Provider');
    isa_ok($model, 'Mango::Catalyst::Model::Provider');
    isa_ok($model->provider, 'Mango::Provider::DBIC');
    is($model->provider_class, 'Mango::Provider::DBIC');
    is_deeply($model->provider->connection_info, ['dsn', 'user', 'password']);
};


## class specific config connection string wins
{
    Mango::Catalyst::Model::Provider->config(
        provider_class => 'Mango::Provider::DBIC',
        connection_info => ['dsnx', 'userx', 'passwordx']
    );

    my $c = Mango::Test::Catalyst->context({
        config => {
            connection_info => ['dsn', 'user', 'password']
        }
    });
    my $model = $c->model('Provider');
    isa_ok($model, 'Mango::Catalyst::Model::Provider');
    isa_ok($model->provider, 'Mango::Provider::DBIC');
    is($model->provider_class, 'Mango::Provider::DBIC');
    is_deeply($model->provider->connection_info, ['dsnx', 'userx', 'passwordx']);
};
