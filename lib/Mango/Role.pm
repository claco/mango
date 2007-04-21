# $Id$
package Mango::Role;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Object/;

    __PACKAGE__->mk_group_accessors('column', qw/name description/);
};

*add_user = \&add_users;

sub add_users {
    my $self = shift;

    return $self->meta->provider->add_users($self, @_);
}

*remove_user = \&remove_users;

sub remove_users {
    my $self = shift;

    return $self->meta->provider->remove_users($self, @_);
};

1;
__END__

=head1 NAME

Mango::Role - Module representing a user role

=head1 SYNOPSIS

    my $roles = $provider->search;
    while (my $role = $roles->next) {
        print $role->name, $role->description;
    };

=head1 DESCRIPTION

Mango::Role represents a user role.

=head1 METHODS

=head2 add_user

Sames as L</add_users>.

=head2 add_users

=over

=item Arguments: @users

=back

Adds a list of users to the current role.

    $role->add_users(23, $otheruser);

See L<Mango::Provider::Roles/add_users> for more details.

=head2 created

Returns the date and time in UTC the role was created as a DateTime
object.

    print $role->created;

=head2 description

=over

=item Arguments: $description

=back

Gets/sets the description of the current role.

    print $role->description;

=head2 destroy

Deletes the current role.

    $role->destroy;

=head2 id

Returns the id of the current role.

    print $role->id;

=head2 name

=over

=item Arguments: $name

=back

Gets/sets the name of the current role.

    print $role->name;

=head2 remove_users

=over

=item Arguments: @users

=back

Removes a list of users from the current role.

    $role->remove_users(23, $otheruser);

See L<Mango::Provider::Roles/remove_users> for more details.

=head2 remove_user

Sames as C<remove_users>.

=head2 update

Saves any changes made to the role back to the provider.

    $role->password('Red');
    $role->update;

Whenever L</update> is called, L</updated> is automatically set to the
current time in UTC.

=head2 updated

Returns the date and time in UTC the role was last updated as a DateTime
object.

    print $role->updated;

=head1 SEE ALSO

L<Mango::Object>, L<Mango::Provider::Roles>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
