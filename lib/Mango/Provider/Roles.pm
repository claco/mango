# $Id$
package Mango::Provider::Roles;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Provider::DBIC/;
    use Scalar::Util ();
};
__PACKAGE__->result_class('Mango::Role');
__PACKAGE__->source_name('Roles');

*add_user = \&add_users;

sub add_users {
    my ($self, $role, @users) = @_;

    if (Scalar::Util::blessed($role) && $role->isa('Mango::Role')) {
        $role = $role->id;
    };

    foreach my $user (@users) {
        if (Scalar::Util::blessed($user) && $user->isa('Mango::User')) {
            $user = $user->id;
        };

        $self->schema->resultset('UsersRoles')->create({
            user_id => $user,
            role_id => $role
        });
    };
};

sub get_by_user {
    my $self = shift;
    my $user = shift;
    my $id = Scalar::Util::blessed($user) ? $user->id : $user ;

    my @results = map {
        $self->result_class->new({
            provider => $self,
            data => {$_->get_inflated_columns}
        })
    } $self->schema->resultset('UsersRoles')->search({
        'user_id' => $id
    })->related_resultset('role')->search->all;

    if (wantarray) {
        return @results;
    } else {
        return Mango::Iterator->new({
            data => \@results
        });
    };
};

1;
__END__
