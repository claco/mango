# $Id$
package Mango::Catalyst::Plugin::Authentication::User;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::Plugin::Authentication::User Class::Accessor::Fast/;

    use Mango::Exception ();
};
__PACKAGE__->mk_accessors(qw/config _context _cart _user _profile/);

sub new {
	my ($class, $c, $config, $user) = @_;

	return unless $user;

	return bless {config => $config, _user => $user, _context => $c}, $class;
};

sub get {
    my ($self, $field) = @_;

    my $object;
    if ($object = $self->get_object and $object->can($field)) {
        return $object->$field;
    } else {
        return undef;
    };
};

sub get_object {
    my $self = shift;

    return $self->_user;
};

sub supported_features {
    my $self = shift;

	return {
        session => 1,
        roles => 1,
        profiles => 1,
        carts => 1
	};
};

sub roles {
    my $self = shift;
    my $name = $self->config->{'role_model'};
    my $model = $self->_context->model($name);

    Mango::Exception->throw('MODEL_NOT_FOUND') unless $model;

    my $role_name_field = $self->config->{'role_name_field'};
    my @roles;

    foreach my $role ($model->search({user => $self->_user})) {
        push @roles, $role->$role_name_field;
    };

    return @roles;
};

sub profile {
    my $self = shift;
    my $name = $self->config->{'profile_model'};
    my $model = $self->_context->model($name);

    Mango::Exception->throw('MODEL_NOT_FOUND') unless $model;

    if (!$self->_profile) {
        my $profile =
            $model->search({user => $self->_user})->first ||
            $model->create({user => $self->_user});

        $self->_profile(
            $profile
        );
    };

    return $self->_profile;
};

sub cart {
    my $self = shift;
    my $name = $self->config->{'cart_model'};
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
