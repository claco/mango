# $Id$
package Catalyst::Plugin::Authentication::Store::Mango::Backend;
use strict;
use warnings;

BEGIN {
    use base qw/Class::Accessor::Grouped/;
    use Catalyst::Plugin::Authentication::Store::Mango::User;
    use Catalyst::Plugin::Authentication::Store::Mango::CachedUser;
    use Catalyst::Plugin::Authentication::Store::Mango::AnonymousUser;
};
__PACKAGE__->mk_group_accessors('inherited', qw/user_model role_model profile_model context/);

sub new {
    my ($class, $config) = @_;

    return bless {%{$config}}, $class;
};

sub get_user {
    my ($self, $id) = @_;
    my $user = $self->user_model->search({$self->{'auth'}{'user_field'} => $id})->first;

    return Catalyst::Plugin::Authentication::Store::Mango::User->new(
        $self,
        $user
    );
};

sub get_anonymous_user {
    my $self = shift;

    return Catalyst::Plugin::Authentication::Store::Mango::AnonymousUser->new(
        $self
    );
};

sub user_supports {
    my $self = shift;

    return Catalyst::Plugin::Authentication::Store::Mango::User->supports(@_);
};

sub from_session {
	my ($self, $c, $id) = @_;
    my $roles = $c->session->{'__mango_user_roles'} || [];

    my $user = bless {
        provider => $self->user_model->provider,
        data => {
            id => $c->session->{'__mango_user_id'},
            username => $id
        }
    }, $self->user_model->result_class;

    return Catalyst::Plugin::Authentication::Store::Mango::CachedUser->new(
        $self,
        $user,
        $roles
    );
};

1;
__END__
