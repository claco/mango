package Catalyst::Plugin::Authentication::Store::Mango::Backend;
use strict;
use warnings;

BEGIN {
    use Catalyst::Plugin::Authentication::Store::Mango::User;
    use Mango::User;
};

sub new {
    my $class = shift;

    return bless {}, $class;
};

sub get_user {
    my ($self, $id) = @_;

    return Catalyst::Plugin::Authentication::Store::Mango::User->new(
        $self,
        Mango::User->getByUserName($id)
    );
};

sub user_supports {
    my $self = shift;

    return Catalyst::Plugin::Authentication::Store::Mango::User->supports(@_);
};

sub from_session {
	my ($self, $c, $id) = @_;

	return $self->get_user($id);
};

1;
__END__
