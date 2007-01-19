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

    if (Scalar::Util::blessed $role && $role->isa('Mango::Role')) {
        $role = $role->id;
    };

    $role = $self->resultset->single({
        id => $role
    });

    foreach my $user (@users) {
        if (Scalar::Util::blessed $user && $user->isa('Mango::User')) {
            $user = $user->id;
        };

        $role->add_to_map_users_roles({
            user_id => $user
        });
    };
};

sub user_roles {
    my ($self, $user) = @_;

    if (Scalar::Util::blessed $user && $user->isa('Mango::User')) {
        $user = $user->id;
    };

    my @results = map {
        $self->result_class->new({
            provider => $self,
            data => {$_->get_columns}
        })
    } $self->resultset->search({
        'map_users_roles.user_id' => $user
    }, {
        join => 'map_users_roles'
    })->all;

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
