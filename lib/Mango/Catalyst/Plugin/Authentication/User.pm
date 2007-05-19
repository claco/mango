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

    Mango::Exception->throw('MODEL_NOT_FOUND', $name) unless $model;

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

    Mango::Exception->throw('MODEL_NOT_FOUND', $name) unless $model;

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

=head1 NAME

Mango::Catalyst::Plugin::Authentication::User - Custom Catalyst Authentication User

=head1 SYNOPSIS

    use Catalyst qw/
        -Debug
        ConfigLoader
        +Mango::Catalyst::Plugin::Authentication
        Static::Simple
    /;
    
    my $user = $c->user;
    print $user->cart->count;

=head1 DESCRIPTION

Mango::Catalyst::Plugin::Authentication::User is a custom authentication user
that uses Mango Catalyst models to present common user information. It is also
the base class for CachedUser and AnonymousUser.

Any unknown method calls are forwarded to the internal user object, which is
an instance or subclass of Mango::User.

=head1 CONSTRUCTOR

=head2 new

There should never be any reason to create one of these yourself. :-)

=head1 METHODS

=head2 cart

Returns a cart for the current user. If no cart exists, one
will be created and assigned to the users current session. The same cart
will be returned for a user before and after they are authenticated.

    my $cart = $c->user->cart;
    print $cart->count;
    $cart->add(...);

Normally, a Mango::Cart is returned. If you are using a custom cart model
that has set its C<result_class> to a custom subclass of Mango::Cart, that
class will be used instead.

=head2 get

=over

=item Arguments: $field

=back

Returns the specified field from the underlying user object.

    $user->get('username');
    
    #same as:
    $user->username;

See L<Catalyst::Plugin::Authentication> for the usage of this method.

=head2 get_object

Returns the underlying user object, which is a Mango::User object.

See L<Catalyst::Plugin::Authentication> for the usage of this method.

=head2 profile

Returns a user profile for the current user. If no profile exists, one
will be created and assigned to the current user.

    my $profile = $c->user->profile;
    print 'Welcome back ', $profile->first_name;

Normally, a Mango::Profile is returned. If you are using a custom profile model
that has set its C<result_class> to a custom subclass of Mango::Profile, that
class will be used instead.

=head2 roles

Returns a list containing the names of all of the roles the current user
belongs to. This method is used by L<Catalyst::Plugin::Authorization::Roles>.

The roles will be loaded form the database every time they are requested.

See L<Catalyst::Plugin::Authentication> for the usage of this method.

=head2 supported_features

Returns an anonymous hash containing the following options:

    session => 1,
    roles => 1,
    profiles => 1,
    carts => 1

=head1 SEE ALSO

L<Catalyst::Plugin::Authentication>,
L<Mango::User>, L<Mango::Profile>, L<Mango::Cart>,
L<Mango::Catalyst::Plugin::Authentication::Store>
L<Mango::Catalyst::Plugin::Authentication::User>
L<Mango::Catalyst::Plugin::Authentication::CachedUser>
L<Mango::Catalyst::Plugin::Authentication::AnonymousUser>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
