# $Id$
package Mango::Catalyst::Plugin::Authentication::AnonymousUser;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Catalyst::Plugin::Authentication::User/;

    use Mango::Exception ();
};
__PACKAGE__->mk_accessors(qw/password/);

sub new {
    my ($class, $c, $config) = @_;
    my $name = $config->{'user_model'};
    my $model = $c->model($name);

    Mango::Exception->throw('MODEL_NOT_FOUND', $name) unless $model;

    my $user = $model->result_class->new({
        id => '0E0',
        username => 'anonymous'
    });

    return bless {
        config => $config,
        _context => $c,
        _user => $user
    }, $class;
};

sub roles {

};

sub profile {
    my $self = shift;
    my $name = $self->config->{'profile_model'};
    my $model = $self->_context->model($name);

    Mango::Exception->throw('MODEL_NOT_FOUND', $name) unless $model;

    if (!$self->_profile) {
        $self->_profile(
            $model->result_class->new({
                first_name => 'Anonymous',
                last_name => 'User'
            })
        );
    };

    return $self->_profile;
};

sub supported_features {
    my $self = shift;

    return {
        roles => 1,
        profiles => 1,
        carts => 1
    };
};

1;

=head1 NAME

Mango::Catalyst::Plugin::Authentication::AnonymousUser - Custom Catalyst Authentication Anonymous User

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

Mango::Catalyst::Plugin::Authentication::AnonymousUser is a custom user for
users that haven't yet been authenticated, i.e. 'anonymous' users.

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
that has set its C<result_class> to a cusotm subclass of Mango::Cart, that
class will be used instead.

=head2 profile

Returns an anonymous profile for the current user. This profile is mostly
empty except for the following fields:

    first_name: Anonymous
    last_name: User

Normally, a Mango::Profile is returned. If you are using a custom profile model
that has set its C<result_class> to a custom subclass of Mango::Profile, that
class will be used instead.

=head2 roles

Returns an empty list.

=head2 support_features

Returns an anonymous hash containing the following options:

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

