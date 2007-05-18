#!perl -wT
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 12;
    use Mango::Test::Catalyst;

    use_ok('Mango::Catalyst::Model::Users');
    use_ok('Mango::Exception', ':try');
};


## make sure it acts like a provider and talks to the db
{
    my $c = Mango::Test::Catalyst->context({
        config => {

        }
    });
    my $model = $c->model('Users');

    ## use faster test schema
    $model->schema(Mango::Test->init_schema);
    isa_ok($model, 'Mango::Catalyst::Model::Users');
    isa_ok($model->provider, 'Mango::Provider::Users');
    is($model->provider_class, 'Mango::Provider::Users');
    is($model->result_class, 'Mango::User');

    ## search
    my $users = $model->search;
    isa_ok($users, 'Mango::Iterator');
    is($users->count, 3);

    ## create
    my $user = $model->create({
        username => 'newuser',
        password => 'newpassword'
    });
    isa_ok($user, 'Mango::User');
    is($model->search->count, 4);

    ## update w/get_by_id
    $user->username('newusername');
    $model->update($user);
    is($model->get_by_id($user->id)->username, 'newusername');

    ## delete
    $model->delete($user);
    is($model->search->count, 3);
};
