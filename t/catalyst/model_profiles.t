#!perl -wT
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Mango::Test tests => 12;
    use Mango::Test::Catalyst;

    use_ok('Mango::Catalyst::Model::Profiles');
    use_ok('Mango::Exception', ':try');
};


## make sure it acts like a provider and talks to the db
{
    my $c = Mango::Test::Catalyst->new;
    my $model = $c->model('Profiles');

    ## use faster test schema
    $model->schema(Mango::Test->init_schema);
    isa_ok($model, 'Mango::Catalyst::Model::Profiles');
    isa_ok($model->provider, 'Mango::Provider::Profiles');
    is($model->provider_class, 'Mango::Provider::Profiles');
    is($model->result_class, 'Mango::Profile');

    ## search
    my $profiles = $model->search;
    isa_ok($profiles, 'Mango::Iterator');
    is($profiles->count, 2);

    ## create
    my $profile = $model->create({
        user => 22,
        first_name => 'newprofile'
    });
    isa_ok($profile, 'Mango::Profile');
    is($model->search->count, 3);

    ## update w/get_by_id
    $profile->first_name('updatedname');
    $model->update($profile);
    is($model->get_by_id($profile->id)->first_name, 'updatedname');

    ## delete
    $model->delete($profile);
    is($model->search->count, 2);
};
