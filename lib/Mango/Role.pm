# $Id: Role.pm 1791 2007-04-10 00:46:54Z claco $
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

    return $self->provider->add_users($self, @_);
}

*remove_user = \&remove_users;

sub remove_users {
    my $self = shift;

    return $self->provider->remove_users($self, @_);
};

1;
__END__

=head1 NAME

Mango::Role - A user role

=head1 SYNOPSIS

    my $roles = $provider->search;
    while (my $role = $roles->next) {
        print $role->name, $role->description;
    };

=head1 DESCRIPTION

Mango::Role represents a user role.

=head1 METHODS

=head2 add_users

=over

=item Arguments: @users

=back

Adds a list of users to the current role.

    $role->add_users(23, $otheruser);

See L<Mango::Provider::Roles/add_users> for more details.

=head2 add_user

Sames as C<add_users>.

=head2 id

Returns id of the current role.

    print $role->id;

=head2 created

Returns the date the role was created as a DateTime object.

    print $role->created;

=head2 updated

Returns the date the role was last updated as a DateTime object.

    print $role->updated;

=head2 name

=over

=item Arguments: $name

=back

Gets/sets the name of the role.

    print $role->name;

=head2 description

=over

=item Arguments: $description

=back

Gets/sets the description of the attribute.

    print $role->description;

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

Saves any changes to the role back to the provider.

=head1 SEE ALSO

L<Mango::Object>, L<Mango::Provider::Roles>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
