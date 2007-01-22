# $Id$
package Catalyst::Plugin::Authentication::Store::Mango::AnonymousUser;
use strict;
use warnings;

BEGIN {
    use base qw/Catalyst::Plugin::Authentication::Store::Mango::User/;
};
__PACKAGE__->mk_accessors(qw/password/);

sub new {
    my ($class, $store) = @_;

    my $user = bless {
        provider => $store->user_model->provider,
        data => {
            id => undef,
            username => 'anonymous'
        }
    }, $store->user_model->result_class;

    return bless {store => $store, user => $user}, $class;
};

sub roles {};

sub profile {
    my $self = shift;

    if (!$self->{'profile'}) {
        $self->{'profile'} = bless {
            provider => $self->store->profile_model->provider,
            data => {
                first_name => 'Anonymous',
                last_name => 'User'
            }
        }, $self->store->profile_model->result_class;
    };

    return $self->{'profile'};
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
__END__
