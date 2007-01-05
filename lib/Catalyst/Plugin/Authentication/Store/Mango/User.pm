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

sub id {
    my $self = shift;

    return $self->user->username;
};

sub supported_features {
	return {
        password => {
            self_check => 1,
		},
        session => 1,
        roles => {
            self_check => 1,
            self_check_any => 1,
        }
	};
};

sub check_password {
	my ($self, $password) = @_;

	return $self->user->password eq $password;
};

sub for_session {
    my $self = shift;

    return $self->id;
};

1;
__END__
