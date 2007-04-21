# $Id$
package Mango::User;
use strict;
use warnings;

BEGIN {
    use base qw/Mango::Object/;

    __PACKAGE__->mk_group_accessors('column', qw/username password/);
};

1;
__END__

=head1 NAME

Mango::User - Module representing an individual user

=head1 SYNOPSIS

    my $user = $provider->search({ username => 'claco' });
    print $user->created;
    $user->password('newpassword');
    $user->update;

=head1 DESCRIPTION

Mango::User represents an individual user.

=head1 METHODS

=head2 created

Returns the date and time in UTC the user was created as a DateTime
object.

    print $user->created;

=head2 destroy

Deletes the current user.

    $user->destroy;

=head2 id

Returns the id of the current user.

    print $user->id;

=head2 update

Saves any changes made to the user back to the provider.

    $user->password('Red');
    $user->update;

Whenever L</update> is called, L</updated> is automatically set to the
current time in UTC.

=head2 updated

Returns the date and time in UTC the user was last updated as a DateTime
object.

    print $user->updated;

=head2 username

=over

=item Arguments: $username

=back

Gets/sets the username of the current user.

    print $user->username;

=head2 password

=over

=item Arguments: $password

=back

Gets/sets the password of the current user.

    print $user->password;

=head1 SEE ALSO

L<Mango::Object>, L<Mango::Provider::Users>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
