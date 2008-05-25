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

sub tests_unauthorized: Test(2) {
    my $self = shift;
    my $m = $self->client;

    $m->get('http://localhost/' . $self->path . '/');
    is( $m->status, 401 );
    $self->validate_markup($m->content);
}

sub tests : Test(88) {
    my $self = shift;
    my $m = $self->client;


    ## normal user not authorized
    $m->get('http://localhost/');
    $self->validate_markup($m->content);
    $m->follow_link_ok({text => 'Login'});
    $self->validate_markup($m->content);
    $m->title_like(qr/login/i);
    $m->submit_form_ok({
        form_id => 'login',
        fields    => {
            username => 'claco',
            password => 'foo'
        }
    });
    $self->validate_markup($m->content);
    $m->get('http://localhost/' . $self->path . '/');
    $self->validate_markup($m->content);
    is( $m->status, 401 );
    $self->validate_markup($m->content);
    $m->follow_link_ok({text => 'Logout'});
    $self->validate_markup($m->content);

    ## login admin
    $m->get_ok('http://localhost/');
    $self->validate_markup($m->content);
    $m->follow_link_ok({text => 'Login'});
    $self->validate_markup($m->content);
    $m->title_like(qr/login/i);
    $m->submit_form_ok({
        form_id => 'login',
        fields    => {
            username => 'admin',
            password => 'admin'
        }
    });
    $self->validate_markup($m->content);


    ## get to the admin roles page
    $m->follow_link_ok({text => 'Admin'});
    $self->validate_markup($m->content);

    my $path = $self->path;
    $m->follow_link_ok({text => 'Roles', url_regex => qr/$path/i});
    $self->validate_markup($m->content);
    $m->content_lacks('Editors');

    my $create = "$path\/create";
    $m->follow_link_ok({url_regex => qr/$create/i});
    $self->validate_markup($m->content);

    ## fail to add role
    $m->submit_form_ok({
        form_id => 'admin_roles_create',
        fields    => {
        }
    });
    $self->validate_markup($m->content);
    $m->content_contains('<li>The name field is required.</li>');
    $m->content_contains('<li>CONSTRAINT_DESCRIPTION_NOT_BLANK</li>');


    ## fail to add role - exists
    $m->submit_form_ok({
        form_id => 'admin_roles_create',
        fields    => {
            name => 'admin'
        }
    });
    $self->validate_markup($m->content);
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
    $self->validate_markup($m->content);
    $m->content_lacks('<li>The name field is required.</li>');
    $m->content_lacks('<li>CONSTRAINT_NAME_UNIQUE</li>');
    $m->content_lacks('<li>CONSTRAINT_DESCRIPTION_NOT_BLANK</li>');
    $m->content_lacks('<li>CONSTRAINT_LAST_NAME_NOT_BLANK</li>');
    is($m->uri->path, '/' . $self->path . '/2/edit/');


    ## edit existing role
    $m->follow_link_ok({text => 'Admin'});
    $self->validate_markup($m->content);
    $m->follow_link_ok({text => 'Roles', url_regex => qr/$path/i});
    $self->validate_markup($m->content);
    $m->content_contains('Editors');
    $m->content_lacks('New Admins Role');
    $m->follow_link_ok({text => 'admin', url_regex => qr/$path.*edit/i});
    $self->validate_markup($m->content);


    ## fail edit
    $m->submit_form_ok({
        form_id => 'admin_roles_edit',
        fields    => {
            description => ''
        }
    });
    $self->validate_markup($m->content);
    $m->content_contains('<li>CONSTRAINT_DESCRIPTION_NOT_BLANK</li>');


    ## continue edit
    $m->submit_form_ok({
        form_id => 'admin_roles_edit',
        fields    => {
            description => 'New Admins Roles'
        }
    });
    $self->validate_markup($m->content);
    $m->content_lacks('<li>CONSTRAINT_DESCRIPTION_NOT_BLANK</li>');
    $m->follow_link_ok({text => 'Roles', url_regex => qr/$path/i});
    $self->validate_markup($m->content);
    $m->content_contains('New Admins Role');
    $m->content_lacks('Administrators');


    ## add claco to admin
    $m->follow_link_ok({text => 'Users', url_regex => qr/admin\/users/i});
    $self->validate_markup($m->content);
    $m->follow_link_ok({text => 'claco', url_regex => qr/admin\/users/i});
    $self->validate_markup($m->content);
    $m->tick('roles', 1);
    $m->submit_form_ok({
        form_id => 'admin_users_edit',
        fields => {
            first_name => 'Christopher',
            last_name  => 'Laco',
            roles => 1
        }
    });
    $self->validate_markup($m->content);
    $m->follow_link_ok({text => 'Users', url_regex => qr/admin\/users/i});
    $self->validate_markup($m->content);
    $m->follow_link_ok({text => 'claco', url_regex => qr/admin\/users/i});
    $self->validate_markup($m->content);
    $m->follow_link_ok({text => 'Logout'});
    $self->validate_markup($m->content);


    ## login claco, now admin
    $m->follow_link_ok({text => 'Login'});
    $self->validate_markup($m->content);
    $m->title_like(qr/login/i);
    $m->submit_form_ok({
        form_id => 'login',
        fields    => {
            username => 'claco',
            password => 'foo'
        }
    });
    $self->validate_markup($m->content);
    $m->follow_link_ok({text => 'Admin'});
    $self->validate_markup($m->content);


    ## delete a role
    $m->follow_link_ok({text => 'Admin'});
    $self->validate_markup($m->content);
    $m->follow_link_ok({text => 'Roles', url_regex => qr/$path/i});
    $self->validate_markup($m->content);
    $m->submit_form_ok({
        form_id => 'admin_roles_delete_2'
    });
    $self->validate_markup($m->content);
    $m->follow_link_ok({text => 'Admin'});
    $self->validate_markup($m->content);
    $m->follow_link_ok({text => 'Roles', url_regex => qr/$path/i});
    $self->validate_markup($m->content);
    $m->content_lacks('Editors');
}

1;