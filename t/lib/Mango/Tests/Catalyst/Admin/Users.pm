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
            user => $user,
            email => 'claco@example.com'
        }
    );
}

sub path {'admin/users'};

sub tests_unauthorized: Test(2) {
    my $self = shift;
    my $m = $self->client;

    $m->get('http://localhost/' . $self->path . '/');
    is( $m->status, 401 );
    $self->validate_markup($m->content);
}

sub tests : Test(107) {
    my $self = shift;
    my $m = $self->client;


    ## no user
    $m->get('http://localhost/users/claco/');
    is($m->status, 404);
    $self->validate_markup($m->content);


    ## login
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


    ## get to the admin users page
    $m->follow_link_ok({text => 'Admin'});
    $self->validate_markup($m->content);

    my $path = $self->path;
    $m->follow_link_ok({text => 'Users', url_regex => qr/$path/i});
    $self->validate_markup($m->content);
    is($m->uri->path, '/' . $self->path . '/');

    my $create = "$path\/create";
    $m->follow_link_ok({url_regex => qr/$create/i});
    $self->validate_markup($m->content);

    ## fail to add user
    $m->submit_form_ok({
        form_id => 'admin_users_create',
        fields    => {
            password => 'a',
            confirm_password => 'b'
        }
    });
    $self->validate_markup($m->content);
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
            confirm_password => 'b',
            email => 'webmaster@example.com',
        }
    });
    $self->validate_markup($m->content);
    $m->content_contains('<li>CONSTRAINT_CONFIRM_PASSWORD_SAME_AS_PASSWORD</li>');
    $m->content_contains('<li>The username requested already exists.</li>');
    $m->content_contains('<li>CONSTRAINT_FIRST_NAME_NOT_BLANK</li>');
    $m->content_contains('<li>CONSTRAINT_LAST_NAME_NOT_BLANK</li>');
    $m->content_contains('<li>CONSTRAINT_EMAIL_UNIQUE</li>');


    ## add new user
    $m->submit_form_ok({
        form_id => 'admin_users_create',
        fields    => {
            username => 'claco',
            password => 'foo',
            confirm_password => 'foo',
            first_name => 'Christopher',
            last_name => 'Laco',
            email => 'claco3@example.com'
        }
    });
    $self->validate_markup($m->content);
    $m->content_lacks('<li>CONSTRAINT_CONFIRM_PASSWORD_SAME_AS_PASSWORD</li>');
    $m->content_lacks('<li>The username field is required.</li>');
    $m->content_lacks('<li>CONSTRAINT_FIRST_NAME_NOT_BLANK</li>');
    $m->content_lacks('<li>CONSTRAINT_LAST_NAME_NOT_BLANK</li>');
    is($m->uri->path, '/' . $self->path . '/3/edit/');
    $m->get_ok('http://localhost/users/claco/');
    $self->validate_markup($m->content);
    $m->content_contains('Christopher Laco');


    ## edit existing user
    $m->follow_link_ok({text => 'Admin'});
    $self->validate_markup($m->content);
    $m->follow_link_ok({text => 'Users', url_regex => qr/$path/i});
    $self->validate_markup($m->content);
    $m->follow_link_ok({text => 'foo', url_regex => qr/$path.*edit/i});
    $self->validate_markup($m->content);


    ## fail edit
    $m->submit_form_ok({
        form_id => 'admin_users_edit',
        fields    => {
            password => 'a',
            confirm_password => 'b',
            email => 'webmaster@example.com'
        }
    });
    $self->validate_markup($m->content);
    $m->content_contains('<li>CONSTRAINT_CONFIRM_PASSWORD_SAME_AS_PASSWORD</li>');
    $m->content_contains('<li>CONSTRAINT_FIRST_NAME_NOT_BLANK</li>');
    $m->content_contains('<li>CONSTRAINT_LAST_NAME_NOT_BLANK</li>');
    $m->content_contains('<li>CONSTRAINT_EMAIL_UNIQUE</li>');


    ## continue edit
    $m->submit_form_ok({
        form_id => 'admin_users_edit',
        fields    => {
            username => 'claco',
            password => 'foo',
            confirm_password => 'foo',
            first_name => 'Foo',
            last_name => 'Bar',
            email => 'foo@example.com'
        }
    });
    $self->validate_markup($m->content);
    $m->content_lacks('<li>CONSTRAINT_CONFIRM_PASSWORD_SAME_AS_PASSWORD</li>');
    $m->content_lacks('<li>The username field is required.</li>');
    $m->content_lacks('<li>CONSTRAINT_FIRST_NAME_NOT_BLANK</li>');
    $m->content_lacks('<li>CONSTRAINT_LAST_NAME_NOT_BLANK</li>');
    $m->content_lacks('<li>CONSTRAINT_EMAIL_UNIQUE</li>');
    $m->follow_link_ok({text => 'Logout'});
    $self->validate_markup($m->content);

    ## login claco
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
    $m->get_ok('http://localhost/users/claco/');
    $self->validate_markup($m->content);
    $m->content_contains('Christopher Laco');
    $m->get('http://localhost/' . $self->path);
    $self->validate_markup($m->content);
    is($m->status, 401);
    $m->follow_link_ok({text => 'Logout'});
    $self->validate_markup($m->content);


    ## logout, login foo
    $m->follow_link_ok({text => 'Login'});
    $self->validate_markup($m->content);
    $m->title_like(qr/login/i);
    $m->submit_form_ok({
        form_id => 'login',
        fields    => {
            username => 'foo',
            password => 'foo'
        }
    });
    $self->validate_markup($m->content);
    $m->get_ok('http://localhost/users/foo/');
    $self->validate_markup($m->content);
    $m->content_contains('Foo Bar');
    $m->get('http://localhost/' . $self->path);
    $self->validate_markup($m->content);
    is($m->status, 401);
    $m->follow_link_ok({text => 'Logout'});
    $self->validate_markup($m->content);


    ## delete user
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
    $m->follow_link_ok({text => 'Admin'});
    $self->validate_markup($m->content);
    $m->follow_link_ok({text => 'Users', url_regex => qr/$path/i});
    $self->validate_markup($m->content);
    $m->submit_form_ok({
        form_id => 'admin_users_delete_3',
    });
    $self->validate_markup($m->content);
    $m->follow_link_ok({text => 'Logout'});
    $self->validate_markup($m->content);


    ## fail login claco
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
    $m->content_contains('<li>The username or password are incorrect.</li>');
    $m->get('http://localhost/users/claco/');
    $self->validate_markup($m->content);
    is($m->status, 404);
}

1;