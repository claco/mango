# $Id$
package Mango::Profile;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Object/;

    __PACKAGE__->mk_group_accessors( 'column',
        qw/user_id first_name last_name email/ );
}

sub full_name {
    my $self = shift;

    return $self->last_name
      ? $self->first_name . ' ' . $self->last_name
      : $self->first_name;
}

1;
__END__

=head1 NAME

Mango::Profile - Module representing a user profile

=head1 SYNOPSIS

    my $profile = $provider->search({ user => 23 });
    print $profile->created;
    $profile->first_name('Christopher');
    $profile->update;

=head1 DESCRIPTION

Mango::Profile represents a user profile containing user information.

=head1 METHODS

=head2 created

Returns the date and time in UTC the profile was created as a DateTime
object.

    print $profile->created;

=head2 destroy

Deletes the current profile.

=head2 first_name

=over

=item Arguments: $first_name

=back

Gets/sets the first name of the current profile.

    print $profile->first_name;

=head2 full_name

Returns the full name ("$firstname $lastname") for the current profile.

=head2 id

Returns the id of the current profile.

    print $profile->id;

=head2 last_name

=over

=item Arguments: $last_name

=back

Gets/sets the last name of the current profile.

    print $profile->last_name;

=head2 email

=over

=item Arguments: $email

=back

Gets/sets the email of the current profile.

    print $profile->email;

=head2 update

Saves any changes made to the profile back to the provider.

    $profile->password('Red');
    $profile->update;

Whenever L</update> is called, L</updated> is automatically set to the
current time in UTC.

=head2 updated

Returns the date and time in UTC the profile was last updated as a DateTime
object.

    print $profile->updated;

=head1 SEE ALSO

L<Mango::Object>, L<Mango::Provider::Profiles>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
