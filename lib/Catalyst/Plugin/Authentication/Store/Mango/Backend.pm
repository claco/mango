# $Id$
package Catalyst::Plugin::Authentication::Store::Mango::Backend;
use strict;
use warnings;

BEGIN {
    use base qw/Class::Accessor::Grouped/;
    use Catalyst::Plugin::Authentication::Store::Mango::User;
    use Catalyst::Plugin::Authentication::Store::Mango::CachedUser;
    use Mango::User;
};
__PACKAGE__->mk_group_accessors('inherited', qw/model context/);

sub new {
    my ($class, $config) = @_;

    return bless {%{$config}}, $class;
};

sub get_user {
    my ($self, $id) = @_;
    my @users = $self->model->search({$self->{'auth'}{'user_field'} => $id});
    my $user = shift @users;

    return Catalyst::Plugin::Authentication::Store::Mango::User->new(
        $self,
        $user
    );
};

sub user_supports {
    my $self = shift;

    return Catalyst::Plugin::Authentication::Store::Mango::User->supports(@_);
};

sub from_session {
	my ($self, $c, $id) = @_;
    my $roles = $c->session->{'__mango_roles'} || [];

    return Catalyst::Plugin::Authentication::Store::Mango::CachedUser->new(
        $self,
        $id,
        $roles
    );
};

1;
__END__
