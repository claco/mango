# $Id$
package Mango::Catalyst::Plugin::Authentication::Store;
use strict;
use warnings;
our $VERSION = $Mango::VERSION;

BEGIN {
    use base qw/Class::Accessor::Grouped/;

    use Mango ();
    #use Mango::Catalyst::Plugin::Authentication::User;
    #use Mango::Catalyst::Plugin::Authentication::CachedUser;
    use Mango::Catalyst::Plugin::Authentication::AnonymousUser;
};

sub new {
    my ($class, $config) = @_;

    return bless {%{$config}}, $class;
};

sub setup {
    my $c = shift;

    $c->config->{authentication}{mango}{model} ||= 'Users';
    $c->config->{authentication}{mango}{user_field} ||= 'username';
    $c->config->{authentication}{mango}{password_field} ||= 'password';
    $c->config->{authentication}{mango}{password_type} ||= 'clear';
    $c->config->{authorization}{mango}{model} ||= 'Roles';
    $c->config->{authorization}{mango}{role_name_field} ||= 'name';
    $c->config->{profiles}{mango}{model} ||= 'Profiles';
    $c->config->{carts}{mango}{model} ||= 'Carts';

    $c->NEXT::setup(@_);
};

#sub find_user {
    
#};

#sub get_user {
#    my ($self, $id) = @_;
#    my $user = $self->user_model->search({$self->{'auth'}{'user_field'} => $id})->first;
#
#    return Catalyst::Plugin::Authentication::Store::Mango::User->new(
#        $self,
#        $user
#    );
#};

#sub user_supports {
#    my $self = shift;
#
#    return Catalyst::Plugin::Authentication::Store::Mango::User->supports(@_);
#};

#sub from_session {
#    my ($self, $c, $id) = @_;
#    my $roles = $c->session->{'__mango_user_roles'} || [];
#
#    my $user = bless {
#        provider => $self->user_model->provider,
#        data => {
#            id => $c->session->{'__mango_user_id'},
#            username => $id
#        }
#    }, $self->user_model->result_class;
#
#    return Catalyst::Plugin::Authentication::Store::Mango::CachedUser->new(
#        $self,
#        $user,
#        $roles
#    );
#};

1;
__END__
