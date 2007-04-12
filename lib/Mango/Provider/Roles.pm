# $Id: Roles.pm 1789 2007-04-06 01:58:24Z claco $
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

*remove_user = \&remove_users;

sub remove_users {
    my ($self, $role, @users) = @_;

    if (Scalar::Util::blessed($role) && $role->isa('Mango::Role')) {
        $role = $role->id;
    };

    $self->schema->resultset('UsersRoles')->search({
        role_id => $role,
        user_id => [map {
            Scalar::Util::blessed($_) ? $_->id : $_
        } @users]
    })->delete;
};

sub search {
    my ($self, $filter, $options) = @_;

    $filter ||= {};
    $options ||= {};

    if (my $user = delete $filter->{'user'}) {
        $filter->{'user.id'} = Scalar::Util::blessed($user) ? $user->id : $user;
        $options->{'distinct'} = 1;
        if (!defined $options->{'join'}) {
            $options->{'join'} = [];
        };
        push @{$options->{'join'}}, {'map_user_role' => 'user'};
    };

    return $self->SUPER::search($filter, $options);
};

1;
__END__

=head1 NAME

Mango::Provider::Roles - Provider class for user role information

=head1 SYNOPSIS

    my $provider = Mango::Provider::Roles->new;
    my $role = $provider->get_by_id(23);

=head1 DESCRIPTION

Mango::Provider::Roles is the provider class responsible for creating,
deleting, updating and searching user role information.

=head1 CONSTRUCTOR

=head2 new

=over

=item Arguments: \%options

=back

Creates a new role provider object. If options are passed to new, those are
sent to C<setup>.

    my $provider = Mango::Provider::Roles->new;

See L<Mango::Provider/new> and L<Mango::Provider::DBIC/new> for a list of other
possible options.

=head1 METHODS

=head2 add_user

=over

=item Arguments: $role, @users

=back

Adds the specified users to the specified role. C<users> can be user objects
or user ids and C<role> can be a role object or a role id.

    my $role = $provider->get_by_id(23);
    $provider->add_users($role, 23, $user);

=head2 add_users

Same as L</add_user>.

=head2 create

=over

=item Arguments: \%data

=back

Creates a new Mango::Role object using the supplied data.

    my $role = $provider->create({
        name => 'Editors',
        description => 'Can edit content'
    });
    
    print $role->name;

=head2 delete

=over

=item Arguments: \%filter

=back

Deletes roles from the provider matching the supplied filter.

    $provider->delete({
        name => 'Editors'
    });

=head2 get_by_id

=over

=item Arguments: $id

=back

Returns a Mango::Role object matching the specified id.

    my $role = $provider->get_by_id(23);

Returns undef if no matching role can be found.

=head2 remove_user

=over

=item Arguments: $role, @users

=back

Removes the specified users from the specified role. C<users> can be user objects
or user ids and C<role> can be a role object or a role id.

    my $role = $provider->get_by_id(23);
    $provider->remove_users($role, 23, $user);

=head2 remove_users

Same as L</remove_user>.

=head2 search

=over

=item Arguments: \%filter, \%options

=back

Returns a list of Mango::Role objects in list context, or a Mango::Iterator
in scalar context matching the specified filter.

    my @roles = $provider->search({
        name => 'A%'
    });
    
    my $iterator = $provider->search({
        name => 'A%'
    });

In addition to using the column names, the following special keys are available:

=over

=item user

This can be a user id, or a user object for which roles are assigned to.

    my @roles = $provider->search({
        user => $user
    });
    
    my $roles = $provider->search({
        user => $user
    });

=back

See L<DBIx::Class::Resultset/ATTRIBUTES> for a list of other possible options.

=head2 update

=over

=item Arguments: $role

=back

Sets the 'updated' column to DateTime->now and saves any changes made to the
role back to the underlying store.

    my $role = $provider->create(\%data);
    $role->description('My New Role');
    
    $provider->update($role);

=head1 SEE ALSO

L<Mango::Provider>, L<Mango::Provider::DBIC>, L<Mango::Role>,
L<DBIx::Class>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
