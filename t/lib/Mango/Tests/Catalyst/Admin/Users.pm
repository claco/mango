# $Id$
package Mango::Tests::Catalyst::Admin::Users;
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
            username => 'foo',
            password => 'bar'
        }
    );

    use_ok('Mango::Provider::Profiles');
    $provider = Mango::Provider::Profiles->new(
        {
            connection_info => [
                'dbi:SQLite:'
                  . Path::Class::file( $self->application, 'data', 'mango.db' )
            ]
        }
    );
    $provider->create(
        {
            user => $user
        }
    );
}

sub path {'admin/users'};

sub tests_unauthorized: Test(1) {
    my $self = shift;
    my $m = $self->client;

    $m->get('http://localhost/' . $self->path . '/');
    is( $m->status, 401 );
}

sub tests : Test(66) {
    my $self = shift;
    my $m = $self->client;


    ## no user
    $m->get('http://localhost/users/claco/');
    is($m->status, 404);


    ## login
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


    ## get to the admin users page
    $m->follow_link_ok({text => 'Admin'});

    my $path = $self->path;
    $m->follow_link_ok({text => 'Users', url_regex => qr/$path/i});

    my $create = "$path\/create";
    $m->follow_link_ok({url_regex => qr/$create/i});


    ## fail to add user
    $m->submit_form_ok({
        form_id => 'admin_users_create',
        fields    => {
            password => 'a',
            confirm_password => 'b'
        }
    });
    $m->content_contains('<li>CONSTRAINT_CONFIRM_PASSWORD_SAME_AS_PASSWORD</li>');
    $m->content_contains('<li>The username field is required.</li>');
    $m->content_contains('<li>CONSTRAINT_FIRST_NAME_NOT_BLANK</li>');
    $m->content_contains('<li>CONSTRAINT_LAST_NAME_NOT_BLANK</li>');


    ## fail to add user - exists
    $m->submit_form_ok({
        form_id => 'admin_users_create',
        fields    => {
            username => 'admin',
            password => 'a',
            confirm_password => 'b'
        }
    });
    $m->content_contains('<li>CONSTRAINT_CONFIRM_PASSWORD_SAME_AS_PASSWORD</li>');
    $m->content_contains('<li>The username requested already exists.</li>');
    $m->content_contains('<li>CONSTRAINT_FIRST_NAME_NOT_BLANK</li>');
    $m->content_contains('<li>CONSTRAINT_LAST_NAME_NOT_BLANK</li>');


    ## add new user
    $m->submit_form_ok({
        form_id => 'admin_users_create',
        fields    => {
            username => 'claco',
            password => 'foo',
            confirm_password => 'foo',
            first_name => 'Christopher',
            last_name => 'Laco'
        }
    });
    $m->content_lacks('<li>CONSTRAINT_CONFIRM_PASSWORD_SAME_AS_PASSWORD</li>');
    $m->content_lacks('<li>The username field is required.</li>');
    $m->content_lacks('<li>CONSTRAINT_FIRST_NAME_NOT_BLANK</li>');
    $m->content_lacks('<li>CONSTRAINT_LAST_NAME_NOT_BLANK</li>');
    is($m->uri->path, '/' . $self->path . '/3/edit/');
    $m->get_ok('http://localhost/users/claco/');
    $m->content_contains('Christopher Laco');


    ## edit existing user
    $m->follow_link_ok({text => 'Admin'});
    $m->follow_link_ok({text => 'Users', url_regex => qr/$path/i});
    $m->follow_link_ok({text => 'foo', url_regex => qr/$path.*edit/i});


    ## fail edit
    $m->submit_form_ok({
        form_id => 'admin_users_edit',
        fields    => {
            password => 'a',
            confirm_password => 'b'
        }
    });
    $m->content_contains('<li>CONSTRAINT_CONFIRM_PASSWORD_SAME_AS_PASSWORD</li>');
    $m->content_contains('<li>CONSTRAINT_FIRST_NAME_NOT_BLANK</li>');
    $m->content_contains('<li>CONSTRAINT_LAST_NAME_NOT_BLANK</li>');


    ## continue edit
    $m->submit_form_ok({
        form_id => 'admin_users_edit',
        fields    => {
            username => 'claco',
            password => 'foo',
            confirm_password => 'foo',
            first_name => 'Foo',
            last_name => 'Bar'
        }
    });
    $m->content_lacks('<li>CONSTRAINT_CONFIRM_PASSWORD_SAME_AS_PASSWORD</li>');
    $m->content_lacks('<li>The username field is required.</li>');
    $m->content_lacks('<li>CONSTRAINT_FIRST_NAME_NOT_BLANK</li>');
    $m->content_lacks('<li>CONSTRAINT_LAST_NAME_NOT_BLANK</li>');
    $m->follow_link_ok({text => 'Logout'});

    ## login claco
    $m->follow_link_ok({text => 'Login'});
    $m->title_like(qr/login/i);
    $m->submit_form_ok({
        form_id => 'login',
        fields    => {
            username => 'claco',
            password => 'foo'
        }
    });
    $m->get_ok('http://localhost/users/claco/');
    $m->content_contains('Christopher Laco');
    $m->get('http://localhost/' . $self->path);
    is($m->status, 401);
    $m->follow_link_ok({text => 'Logout'});


    ## logout, login foo
    $m->follow_link_ok({text => 'Login'});
    $m->title_like(qr/login/i);
    $m->submit_form_ok({
        form_id => 'login',
        fields    => {
            username => 'foo',
            password => 'foo'
        }
    });
    $m->get_ok('http://localhost/users/foo/');
    $m->content_contains('Foo Bar');
    $m->get('http://localhost/' . $self->path);
    is($m->status, 401);
    $m->follow_link_ok({text => 'Logout'});


    ## delete user
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
    $m->follow_link_ok({text => 'Admin'});
    $m->follow_link_ok({text => 'Users', url_regex => qr/$path/i});
    $m->submit_form_ok({
        form_id => 'admin_users_delete',
        form_number => 3
    });
    $m->follow_link_ok({text => 'Logout'});


    ## fail login claco
    $m->follow_link_ok({text => 'Login'});
    $m->title_like(qr/login/i);
    $m->submit_form_ok({
        form_id => 'login',
        fields    => {
            username => 'claco',
            password => 'foo'
        }
    });
    $m->content_contains('<li>The username or password are incorrect.</li>');
    $m->get('http://localhost/users/claco/');
    is($m->status, 404);
}

1;