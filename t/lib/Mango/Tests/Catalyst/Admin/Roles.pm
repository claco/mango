# $Id$
package Mango::Tests::Catalyst::Admin::Roles;
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

    use_ok('Mango::Provider::Users');
    my $provider = Mango::Provider::Users->new(
        {
            connection_info => [
                'dbi:SQLite:'
                  . Path::Class::file( $self->application, 'data', 'mango.db' )
            ]
        }
    );
    my $user = $provider->create(
        {
            username => 'claco',
            password => 'foo'
        }
    );
}

sub path {'admin/roles'};

sub tests_unauthorized: Test(1) {
    my $self = shift;
    my $m = $self->client;

    $m->get('http://localhost/' . $self->path . '/');
    is( $m->status, 401 );
}

sub tests : Test(53) {
    my $self = shift;
    my $m = $self->client;


    ## normal user not authorized
    $m->get('http://localhost/');
    $m->follow_link_ok({text => 'Login'});
    $m->title_like(qr/login/i);
    $m->submit_form_ok({
        form_id => 'login',
        fields    => {
            username => 'claco',
            password => 'foo'
        }
    });
    $m->get('http://localhost/' . $self->path . '/');
    is( $m->status, 401 );
    $m->follow_link_ok({text => 'Logout'});


    ## login admin
    $m->get_ok('http://localhost/');
    $m->follow_link_ok({text => 'Login'});
    $m->title_like(qr/login/i);
    $m->submit_form_ok({
        form_id => 'login',
        fields    => {
            username => 'admin',
            password => 'admin'
        }
    });


    ## get to the admin roles page
    $m->follow_link_ok({text => 'Admin'});

    my $path = $self->path;
    $m->follow_link_ok({text => 'Roles', url_regex => qr/$path/i});
    $m->content_lacks('Editors');

    my $create = "$path\/create";
    $m->follow_link_ok({url_regex => qr/$create/i});


    ## fail to add role
    $m->submit_form_ok({
        form_id => 'admin_roles_create',
        fields    => {
        }
    });
    $m->content_contains('<li>The name field is required.</li>');
    $m->content_contains('<li>CONSTRAINT_DESCRIPTION_NOT_BLANK</li>');


    ## fail to add role - exists
    $m->submit_form_ok({
        form_id => 'admin_roles_create',
        fields    => {
            name => 'admin'
        }
    });
    $m->content_contains('<li>CONSTRAINT_NAME_UNIQUE</li>');
    $m->content_contains('<li>CONSTRAINT_DESCRIPTION_NOT_BLANK</li>');


    ## add new role
    $m->submit_form_ok({
        form_id => 'admin_roles_create',
        fields    => {
            name => 'editor',
            description => 'Editors'
        }
    });
    $m->content_lacks('<li>The name field is required.</li>');
    $m->content_lacks('<li>CONSTRAINT_NAME_UNIQUE</li>');
    $m->content_lacks('<li>CONSTRAINT_DESCRIPTION_NOT_BLANK</li>');
    $m->content_lacks('<li>CONSTRAINT_LAST_NAME_NOT_BLANK</li>');
    is($m->uri->path, '/' . $self->path . '/2/edit/');


    ## edit existing role
    $m->follow_link_ok({text => 'Admin'});
    $m->follow_link_ok({text => 'Roles', url_regex => qr/$path/i});
    $m->content_contains('Editors');
    $m->content_lacks('New Admins Role');
    $m->follow_link_ok({text => 'admin', url_regex => qr/$path.*edit/i});


    ## fail edit
    $m->submit_form_ok({
        form_id => 'admin_roles_edit',
        fields    => {
            description => ''
        }
    });
    $m->content_contains('<li>CONSTRAINT_DESCRIPTION_NOT_BLANK</li>');


    ## continue edit
    $m->submit_form_ok({
        form_id => 'admin_roles_edit',
        fields    => {
            description => 'New Admins Roles'
        }
    });
    $m->content_lacks('<li>CONSTRAINT_DESCRIPTION_NOT_BLANK</li>');
    $m->follow_link_ok({text => 'Roles', url_regex => qr/$path/i});
    $m->content_contains('New Admins Role');
    $m->content_lacks('Administrators');


    ## add claco to admin
    $m->follow_link_ok({text => 'Users', url_regex => qr/admin\/users/i});
    $m->follow_link_ok({text => 'claco', url_regex => qr/admin\/users/i});
    $m->tick('roles', 1);
    $m->submit_form_ok({
        form_id => 'admin_users_edit',
        fields => {
            first_name => 'Christopher',
            last_name  => 'Laco',
            roles => 1
        }
    });
    $m->follow_link_ok({text => 'Users', url_regex => qr/admin\/users/i});
    $m->follow_link_ok({text => 'claco', url_regex => qr/admin\/users/i});
    $m->follow_link_ok({text => 'Logout'});


    ## login claco, now admin
    $m->follow_link_ok({text => 'Login'});
    $m->title_like(qr/login/i);
    $m->submit_form_ok({
        form_id => 'login',
        fields    => {
            username => 'claco',
            password => 'foo'
        }
    });
    $m->follow_link_ok({text => 'Admin'});


    ## delete a role
    $m->follow_link_ok({text => 'Admin'});
    $m->follow_link_ok({text => 'Roles', url_regex => qr/$path/i});
    $m->submit_form_ok({
        form_id => 'admin_roles_delete_2'
    });
    $m->follow_link_ok({text => 'Admin'});
    $m->follow_link_ok({text => 'Roles', url_regex => qr/$path/i});
    $m->content_lacks('Editors');
}

1;