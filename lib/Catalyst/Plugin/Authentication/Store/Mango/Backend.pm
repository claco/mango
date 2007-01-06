# $Id$
package Catalyst::Plugin::Authentication::Store::Mango::Backend;
use strict;
use warnings;

BEGIN {
    use base qw/Class::Accessor::Grouped/;
    use Catalyst::Plugin::Authentication::Store::Mango::User;
    use Mango::User;
};
__PACKAGE__->mk_group_accessors('inherited', qw/model/);

sub new {
    my $class = shift;

    return bless {}, $class;
};

sub get_user {
    my ($self, $id) = @_;

    return Catalyst::Plugin::Authentication::Store::Mango::User->new(
        $self,
        $self->model->search({username => $id})
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
