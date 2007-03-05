# $Id$
package Catalyst::Plugin::Authentication::Store::Mango::User;
use strict;
use warnings;
use overload '""' => sub {shift->id}, fallback => 1;

BEGIN {
    use base qw/Catalyst::Plugin::Authentication::User Class::Accessor::Fast/;
};
__PACKAGE__->mk_accessors(qw/user store/);

sub new {
	my ($class, $store, $user) = @_;

	return unless $user;

	return bless {store => $store, user => $user}, $class;
};

sub hash_algorithm {
    my $self = shift;

    return $self->store->{'auth'}{'password_hash_type'};
};

sub password_pre_salt {
    my $self = shift;

    return $self->store->{'auth'}{'password_pre_salt'};
};

sub password_post_salt {
    my $self = shift;

    return $self->store->{'auth'}{'password_post_salt'};
};

sub password_salt_len {
    my $self = shift;

    return $self->store->{'auth'}{'password_salt_len'};
};

sub id {
    my $self = shift;
    my $user_field = $self->store->{'auth'}{'user_field'};

    return $self->user->$user_field;
};

*crypted_password = \&password;
*hashed_password = \&password;

sub password {
    my $self = shift;
    my $password_field = $self->store->{'auth'}{'password_field'};

    return $self->user->$password_field;
};

sub supported_features {
    my $self = shift;

	return {
        password => {
            $self->store->{'auth'}{'password_type'} => 1,
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

    if (!$self->{'profile'}) {
        $self->{'profile'} = $self->store->profile_model->user_profile($self->user->id);
    };

    return $self->{'profile'};
};

sub cart {
    my $self = shift;
    my $cart;

    if (!$self->{'cart'}) {
        if (my $cart_id = $self->store->context->session->{'__mango_cart_id'}) {
            $cart = $self->store->cart_model->search({id => $cart_id})->first;
        };

        if (!$cart) {
            $cart = $self->store->cart_model->create({});
            $self->store->context->session->{'__mango_cart_id'} = $cart->id;
        };

        $self->{'cart'} = $cart;
        $self->store->context->session_expires(1);
    };

    return $self->{'cart'};
};

sub AUTOLOAD {
    my ($method) = (our $AUTOLOAD =~ /([^:]+)$/);
    return if $method =~ /(DESTROY|ACCEPT_CONTEXT|config)/;

    return shift->user->$method(@_);
};

1;
__END__
