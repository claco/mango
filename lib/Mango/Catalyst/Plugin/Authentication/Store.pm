# $Id$
package Mango::Catalyst::Plugin::Authentication::Store;
use strict;
use warnings;
our $VERSION = $Mango::VERSION;

BEGIN {
    use base qw/Class::Accessor::Fast/;

    use Mango ();
    use Mango::Catalyst::Plugin::Authentication::User ();
    use Mango::Catalyst::Plugin::Authentication::CachedUser ();
    use Mango::Catalyst::Plugin::Authentication::AnonymousUser ();
};
__PACKAGE__->mk_accessors(qw/config/);

sub new {
    my ($class, $config, $app) = @_;

    $config->{'user_model'} ||= 'Users';
    $config->{'user_name_field'} ||= 'username';
    $config->{'role_model'} ||= 'Roles';
    $config->{'role_name_field'} ||= 'name';
    $config->{'profile_model'} ||= 'Profiles';
    $config->{'cart_model'} ||= 'Carts';

    return bless {config => $config}, $class;
};

sub anonymous_user {
    my ($self, $c) = (shift, shift);

    return Mango::Catalyst::Plugin::Authentication::AnonymousUser->new(
        $c, $self->config, @_
    );
};

sub find_user {
    my ($self, $authinfo, $c) = @_;
    my $user_name_field = $self->config->{'user_name_field'};
    my $name = $self->config->{'user_model'};
    my $model = $c->model($name);

    Mango::Exception->throw('MODEL_NOT_FOUND', $name) unless $model;

    my $user = $model->search({
        $user_name_field => $authinfo->{'username'}
    })->first;

    if ($user) {
        return Mango::Catalyst::Plugin::Authentication::User->new(
            $c, $self->config, $user
        );
    } else {
        return undef;
    };
};

sub user_supports {
    my $self = shift;

    return Mango::Catalyst::Plugin::Authentication::Store::User->supports(@_);
};

sub for_session {
    my ($self, $c, $user) = @_;

    ## don't store the password
    $user->password(undef);

    return {
        user => {$user->get_columns},
        profile => {$user->profile->get_columns},
        roles => [$user->roles]
    };
};

sub from_session {
    my ($self, $c, $data) = @_;

    ## restore user as user model result class
    my $uname = $self->config->{'user_model'};
    my $umodel = $c->model($uname);
    Mango::Exception->throw('MODEL_NOT_FOUND', $uname) unless $umodel;
    my $user = bless $data->{'user'}, $umodel->result_class;

    ## restore profile as profile model result class
    my $pname = $self->config->{'profile_model'};
    my $pmodel = $c->model($pname);
    Mango::Exception->throw('MODEL_NOT_FOUND', $pname) unless $pmodel;
    my $profile = bless $data->{'profile'}, $pmodel->result_class;

    my $restored = Mango::Catalyst::Plugin::Authentication::CachedUser->new(
        $c, $self->config, $user
    );
    $restored->_profile($profile);

    ## restore role information
    $restored->_roles($data->{'roles'});

    return $restored;
};

1;
__END__

=head1 NAME

Mango::Catalyst::Plugin::Authentication::Store - Custom Catalyst Authentication Store

=head1 SYNOPSIS

    use Catalyst qw/
        -Debug
        ConfigLoader
        +Mango::Catalyst::Plugin::Authentication
        Static::Simple
    /;

=head1 DESCRIPTION

Mango::Catalyst::Plugin::Authentication::Store is a custom authentication store
that uses Mango Catalyst models to authenticate users.

To use this store, simply add it to the appropriate realm configuration:

    authentication:
      default_realm: mango
      realms:
        mango:
          credential:
            class: Password
            password_field: password
            password_type: clear
          store:
            class: +Mango::Catalyst::Plugin::Authentication::Store
            cart_model: Carts
            profile_model: Profiles
            role_model: Roles
            user_model: Users

=head1 CONFIGURATION

The following configuration options are available when using this store:

    authentication:
      default_realm: mango
      realms:
        mango:
          credential:
            class: Password
            password_field: password
            password_type: clear
          store:
            class: +Mango::Catalyst::Plugin::Authentication::Store
            cart_model: Carts
            profile_model: Profiles
            role_model: Roles
            user_model: Users

=head2 cart_model

The name of the model used to fetch carts. This model can be any model
that inherits from Mango::Catalyst::Model::Carts. The default model is
<Carts>.

=head2 profile_model

The name of the model used to fetch profiles. This model can be any model
that inherits from Mango::Catalyst::Model::Profiles. The default model is
<Profiles>.

=head2 role_model

The name of the model used to fetch user roles. This model can be any model
that inherits from Mango::Catalyst::Model::Roles. The default model is
<Roles>.

=head2 user_model

The name of the model used to fetch users. This model can be any model
that inherits from Mango::Catalyst::Model::Users. The default model is
<Users>.

=head1 CONSTRUCTOR

=head2 new

See L<Catalyst::Plugin::Authentication> for more information about how
custom stores are created and used.

=head1 METHODS

=head2 anonymous_user

Returns an AnonymousUser object for the current user.

=head2 find_user

Returns a User object for the specified username.

=head2 for_session

Returns an anonymous hash containing the current users user, role and profile
information to be saved into the current users session.

=head2 from_session

Returns a CachedUser object restored from the current users session containing
user, profile and role information.

=head2 user_supports

Returns a hash containing the support features.

=head1 SEE ALSO

L<Catalyst::Plugin::Authentication>,
L<Mango::Catalyst::Plugin::Authentication::Store>
L<Mango::Catalyst::Plugin::Authentication::User>
L<Mango::Catalyst::Plugin::Authentication::CachedUser>
L<Mango::Catalyst::Plugin::Authentication::AnonymousUser>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
