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

    return $restored;
};

1;
__END__
