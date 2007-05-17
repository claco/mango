#!perl -wT
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 12;
    use Mango::Test::Catalyst;

    use_ok('Mango::Catalyst::Model::Roles');
    use_ok('Mango::Exception', ':try');
};


## make sure it acts like a provider and talks to the db
{
    my $c = Mango::Test::Catalyst->context({
        config => {
            connection_info => [
                Mango::Test->init_schema->dsn,
                undef,
                undef,
                {AutoCommit => 1}
            ]
        }
    });
    my $model = $c->model('Roles');
    isa_ok($model, 'Mango::Catalyst::Model::Roles');
    isa_ok($model->provider, 'Mango::Provider::Roles');
    is($model->provider_class, 'Mango::Provider::Roles');
    is($model->result_class, 'Mango::Role');

    ## search
    my $roles = $model->search;
    isa_ok($roles, 'Mango::Iterator');
    is($roles->count, 2);

    ## create
    my $role = $model->create({
        name => 'newrole'
    });
    isa_ok($role, 'Mango::Role');
    is($model->search->count, 3);

    ## update w/get_by_id
    $role->description('newroledescription');
    $model->update($role);
    is($model->get_by_id($role->id)->description, 'newroledescription');

    ## delete
    $model->delete($role);
    is($model->search->count, 2);
};
