# $Id$
package Mango::Catalyst::Plugin::Authentication::User;
use strict;
use warnings;
use overload '""' => sub {shift->id}, fallback => 1;

BEGIN {
    use base qw/Catalyst::Plugin::Authentication::User Class::Accessor::Fast/;

    use Mango::Exception ();
};
__PACKAGE__->mk_accessors(qw/_context _user _profile _cart/);

sub new {
	my ($class, $store, $user) = @_;

	return unless $user;

	return bless {user => $user}, $class;
};

sub hash_algorithm {
    my $self = shift;

    return $self->_context->config->{'auth'}{'password_hash_type'};
};

sub password_pre_salt {
    my $self = shift;

    return $self->_context->config->{'auth'}{'password_pre_salt'};
};

sub password_post_salt {
    my $self = shift;

    return $self->_context->config->{'auth'}{'password_post_salt'};
};

sub password_salt_len {
    my $self = shift;

    return $self->_context->config->{'auth'}{'password_salt_len'};
};

sub id {
    my $self = shift;
    my $user_field = $self->_context->config->{authentication}{mango}{user_field};

    return $self->_user->$user_field;
};

*crypted_password = \&password;
*hashed_password = \&password;

sub password {
    my $self = shift;
    my $password_field = $self->_context->config->{'auth'}{'password_field'};

    return $self->user->$password_field;
};

sub supported_features {
    my $self = shift;

	return {
        password => {
            $self->_context->config->{'auth'}{'password_type'} => 1,
		},
        session => 1,
        roles => 1,
        profiles => 1,
        carts => 1
	};
};

sub for_session {
    my $self = shift;

    $self->store->context->session->{'__mango_user_roles'} = [$self->roles];
    $self->store->context->session->{'__mango_user_id'} = $self->user->id;

    return $self->id;
};

sub roles {
    my $self = shift;

    unless ($self->store->{'authz'}) {
        Catalyst::Exception->throw(
            message => 'No authorization configuration defined'
        );
    };

    my $role_name_field = $self->store->{'authz'}{'role_name_field'};
    my @roles;

    foreach my $role ($self->store->role_model->get_by_user($self->user->id)) {
        push @roles, $role->$role_name_field;
    };

    return @roles;
};

sub profile {
    my $self = shift;
    my $name = $self->_context->config->{profiles}{mango}{model};
    my $model = $self->_context->model($name);

    Mango::Exception->throw('MODEL_NOT_FOUND') unless $model;

    if (!$self->_profile) {
        $self->_profile(
            $model->search({
                user => $self->_user
            })
        );
    };

    return $self->_profile;
};

sub cart {
    my $self = shift;
    my $name = $self->_context->config->{carts}{mango}{model};
    my $model = $self->_context->model($name);
    my $cart;

    Mango::Exception->throw('MODEL_NOT_FOUND', $name) unless $model;

    if (!$self->_cart) {
        if (my $cart_id = $self->_context->session->{'__mango_cart_id'}) {
            $cart = $model->get_by_id($cart_id);
        };

        if (!$cart) {
            $cart = $model->create({});
            $self->_context->session->{'__mango_cart_id'} = $cart->id;
        };

        $self->_cart($cart);
        $self->_context->session_expires(1);
    };

    return $self->_cart;
};

sub AUTOLOAD {
    my ($method) = (our $AUTOLOAD =~ /([^:]+)$/);
    return if $method =~ /(DESTROY|ACCEPT_CONTEXT|config)/;

    return shift->_user->$method(@_);
};

1;
__END__
